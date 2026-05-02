import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chapter.dart';
import '../models/annotation.dart';
import '../providers/app_providers.dart';
import '../services/storage_service.dart';
import 'inline_search.dart';
import 'search_util.dart';
import 'editor/mode_button.dart';
import 'editor/annotated_text_controller.dart';
import 'editor/decoration_painter.dart';
import 'editor/search_highlight_painter.dart';
import '../utils/render_utils.dart';

const _uuid = Uuid();

class _SaveIntent extends Intent {}

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _writeController = TextEditingController();
  final _writeScrollController = ScrollController();
  final _writeFocusNode = FocusNode();

  final _readController = AnnotatedTextController();
  final _readScrollController = ScrollController();
  final _readFocusNode = FocusNode();

  final _titleController = TextEditingController();

  bool _isReadingMode = false;
  bool _isLoading = false;
  Chapter? _currentChapter;

  bool _isEditingTitle = false;

  AnnotationType _activeType = AnnotationType.underline;
  String? _activeColor;
  bool _typeLocked = false;

  bool _selectionActive = false;
  Offset _toolbarOffset = Offset.zero;
  bool _toolbarBelow = true;

  int _wordCount = 0;
  final _readAreaKey = GlobalKey();
  RenderEditable? _cachedRenderEditable;

  Timer? _saveDebounceTimer;
  DateTime? _lastSaveTime;
  bool _savingGuard = false;

  bool _showInlineSearch = false;
  String _inlineSearchQuery = '';
  List<SearchMatch> _searchMatches = [];
  int _currentSearchIndex = -1;

  final _writeAreaKey = GlobalKey();

  static int _countNonWhitespace(String text) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c != 0x20 && c != 0x0A && c != 0x0D && c != 0x09) count++;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _writeController.addListener(_updateWordCount);
    _writeController.addListener(_onWriteChanged);
    _readController.addListener(_onReadSelectionChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCurrentChapter();
    });
  }

  @override
  void deactivate() {
    final notifier = ref.read(onExitSaveProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.state = null;
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    _writeController.removeListener(_updateWordCount);
    _writeController.removeListener(_onWriteChanged);
    _writeController.dispose();
    _writeScrollController.dispose();
    _writeFocusNode.dispose();
    _readController.dispose();
    _readScrollController.dispose();
    _readFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ==================== 字数统计 ====================

  void _updateWordCount() {
    final text = _isReadingMode ? _readController.text : _writeController.text;
    final chars = _countNonWhitespace(text);
    if (chars != _wordCount) {
      setState(() => _wordCount = chars);
    }
  }

  // ==================== 节流保存（最低间隔1秒） ====================

  void _onWriteChanged() {
    if (!_isReadingMode) {
      _markDirty();
      _scheduleDebouncedSave();
    }
  }

  void _onAnnotationsChanged() {
    if (_isReadingMode) {
      _markDirty();
      _scheduleDebouncedSave();
    }
  }

  void _markDirty() {
    ref.read(hasUnsavedChangesProvider.notifier).state = true;
  }

  void _clearDirty() {
    ref.read(hasUnsavedChangesProvider.notifier).state = false;
  }

  void _scheduleDebouncedSave() {
    _saveDebounceTimer?.cancel();
    final now = DateTime.now();
    final elapsed =
        _lastSaveTime != null ? now.difference(_lastSaveTime!) : null;
    if (elapsed == null || elapsed > const Duration(seconds: 1)) {
      _saveCurrentChapter(silent: true);
    } else {
      final remainingMs =
          1000 - elapsed.inMilliseconds;
      _saveDebounceTimer = Timer(Duration(milliseconds: remainingMs), () {
        _saveCurrentChapter(silent: true);
      });
    }
  }

  // ==================== 章节切换（无弹窗，直接保存后切换） ====================

  void _handleChapterSwitch() {
    if (_savingGuard) return;
    _savingGuard = true;
    Future.microtask(() async {
      await _saveCurrentChapter(silent: true);
      if (mounted) _loadCurrentChapter();
      _savingGuard = false;
    });
  }

  void _handleChapterLeave() {
    _saveDebounceTimer?.cancel();
    _saveCurrentChapter(silent: true);
    _clearChapterState();
  }

  void _clearChapterState() {
    _writeController.text = '';
    _readController.text = '';
    _readController.annotations = [];
    _currentChapter = null;
    _clearDirty();
  }

  // ==================== 保存 ====================

  Future<void> _saveCurrentChapter({bool silent = false}) async {
    final bookId = ref.read(currentBookIdProvider);
    final volumeId = ref.read(currentVolumeIdProvider);
    final chapterId = ref.read(currentChapterIdProvider);
    if (bookId == null || volumeId == null || chapterId == null) return;
    if (_currentChapter == null) return;

    final text = _isReadingMode ? _readController.text : _writeController.text;
    _currentChapter!.content = text;
    if (_isReadingMode) {
      _currentChapter!.annotations = List.from(_readController.annotations);
    }
    _currentChapter!.updatedAt = DateTime.now();

    final storage = StorageService.instance;
    await storage.saveChapter(bookId, volumeId, _currentChapter!);

    _clearDirty();
    _lastSaveTime = DateTime.now();

    if (!silent && mounted) {
      ref.read(toastProvider.notifier).show('保存成功');
    }
  }

  // ==================== 加载章节 ====================

  Future<void> _loadCurrentChapter() async {
    if (!mounted) return;
    final bookId = ref.read(currentBookIdProvider);
    final volumeId = ref.read(currentVolumeIdProvider);
    final chapterId = ref.read(currentChapterIdProvider);
    if (bookId == null || volumeId == null || chapterId == null) return;
    await _loadChapter(bookId, volumeId, chapterId);
  }

  Future<void> _loadChapter(
    String bookId,
    String volumeId,
    String chapterId,
  ) async {
    setState(() => _isLoading = true);
    final storage = StorageService.instance;
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);

    if (chapter != null) {
      _writeController.text = chapter.content;
      _readController.text = chapter.content;
      _readController.annotations = List.from(chapter.annotations);
      _currentChapter = chapter;
    }
    _isReadingMode = false;
    _clearDirty();
    _lastSaveTime = null;
    setState(() => _isLoading = false);
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    ref.listen(currentChapterIdProvider, (prev, next) {
      if (!mounted) return;
      if (prev != next && next != null) {
        _handleChapterSwitch();
      } else if (prev != null && next == null) {
        _handleChapterLeave();
      }
    });

    ref.listen(autoInlineSearchProvider, (prev, next) {
      if (next != null && next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _showInlineSearch = true;
              _inlineSearchQuery = next;
            });
            ref.read(autoInlineSearchProvider.notifier).state = null;
          }
        });
      }
    });

    if (ref.read(onExitSaveProvider) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(onExitSaveProvider.notifier).state = () async {
            await _saveCurrentChapter(silent: true);
          };
        }
      });
    }

    final bookId = ref.watch(currentBookIdProvider);
    final chapterId = ref.watch(currentChapterIdProvider);

    if (bookId == null) {
      return _buildEmptyState('请先在左侧创建或选择一本书籍');
    }
    if (chapterId == null) {
      return _buildBookInfo(bookId, ref);
    }
    if (_isLoading || _currentChapter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _SaveIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) => _saveCurrentChapter(),
          ),
        },
        child: Column(
          children: [
            if (_showInlineSearch)
              InlineSearchOverlay(
                key: ValueKey(_inlineSearchQuery),
                controller: _isReadingMode ? _readController : _writeController,
                scrollController:
                    _isReadingMode ? _readScrollController : _writeScrollController,
                textAreaKey:
                    _isReadingMode ? _readAreaKey : _writeAreaKey,
                initialQuery: _inlineSearchQuery,
                onClose: () => setState(() {
                  _showInlineSearch = false;
                  _inlineSearchQuery = '';
                  _searchMatches = [];
                  _currentSearchIndex = -1;
                }),
                onMatchesChanged: (matches, query, currentIndex) => setState(() {
                  _searchMatches = matches;
                  _inlineSearchQuery = query;
                  _currentSearchIndex = currentIndex;
                }),
              ),
            _buildTitleBar(),
            Expanded(
              child: _isReadingMode ? _buildReadingMode() : _buildWritingMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    final title = _currentChapter?.title ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _isEditingTitle
                ? TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _submitTitle(),
                    onTapOutside: (_) => _submitTitle(),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingTitle = true;
                        _titleController.text = _currentChapter?.title ?? '';
                      });
                    },
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          if (_isEditingTitle)
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              tooltip: '确认',
              onPressed: _submitTitle,
              visualDensity: VisualDensity.compact,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '字数: $_wordCount',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          ModeButton(
            icon: Icons.edit,
            label: '写作',
            isActive: !_isReadingMode,
            onPressed: () => _switchMode(false),
          ),
          ModeButton(
            icon: Icons.visibility,
            label: '阅读',
            isActive: _isReadingMode,
            onPressed: () => _switchMode(true),
          ),
          IconButton(
            icon: Icon(
              _showInlineSearch ? Icons.search_off : Icons.search,
              size: 18,
            ),
            tooltip: '章节内搜索',
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() {
              _showInlineSearch = !_showInlineSearch;
              if (!_showInlineSearch) {
                _inlineSearchQuery = '';
                _searchMatches = [];
              }
            }),
          ),
        ],
      ),
    );
  }

  void _submitTitle() {
    if (_titleController.text.isNotEmpty && _currentChapter != null) {
      _currentChapter!.title = _titleController.text;
    }
    setState(() => _isEditingTitle = false);
  }

  void _switchMode(bool toReading) {
    if (toReading == _isReadingMode) return;
    if (!toReading) {
      _writeController.text = _readController.text;
    } else {
      _readController.text = _writeController.text;
      _readController.annotations = List.from(
        _currentChapter?.annotations ?? [],
      );
    }
    setState(() {
      _isReadingMode = toReading;
      _activeType = AnnotationType.underline;
      _activeColor = null;
      _typeLocked = false;
      _selectionActive = false;
    });
    _updateWordCount();
  }

  // ==================== 写作模式 ====================

  Widget _buildWritingMode() {
    final showHighlights = _showInlineSearch && _searchMatches.isNotEmpty;
    return Container(
      key: _writeAreaKey,
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Scrollbar(
            controller: _writeScrollController,
            thumbVisibility: true,
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thickness: WidgetStateProperty.all(0.0),
                ),
              ),
              child: TextField(
                controller: _writeController,
                focusNode: _writeFocusNode,
                scrollController: _writeScrollController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16),
                strutStyle: const StrutStyle(
                  fontSize: 16,
                  height: 1.6,
                  forceStrutHeight: true,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(24),
                  hintText: '开始创作...',
                ),
              ),
            ),
          ),
          if (showHighlights)
            CustomPaint(
              painter: SearchHighlightPainter(
                matches: _searchMatches,
                currentIndex: _currentSearchIndex,
                areaKey: _writeAreaKey,
                scrollController: _writeScrollController,
                textController: _writeController,
              ),
            ),
        ],
      ),
    );
  }

  // ==================== 阅读模式 ====================

  Widget _buildReadingMode() {
    final hasSelection =
        _readController.selection.isValid &&
        !_readController.selection.isCollapsed;
    final showToolbar = hasSelection || _selectionActive;

    return GestureDetector(
      onTap: () {
        _readFocusNode.unfocus();
        setState(() => _selectionActive = false);
      },
      child: Container(
        key: _readAreaKey,
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            CustomPaint(
              painter: DecorationPainter(
                annotations: _readController.annotations,
                areaKey: _readAreaKey,
                scrollController: _readScrollController,
                textController: _readController,
                drawHighlights: true,
                drawStrikethroughs: false,
              ),
              foregroundPainter: DecorationPainter(
                annotations: _readController.annotations,
                areaKey: _readAreaKey,
                scrollController: _readScrollController,
                textController: _readController,
                drawHighlights: false,
                drawStrikethroughs: true,
              ),
              child: Scrollbar(
                controller: _readScrollController,
                thumbVisibility: true,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thickness: WidgetStateProperty.all(0.0),
                    ),
                  ),
                  child: TextField(
                    focusNode: _readFocusNode,
                    controller: _readController,
                    scrollController: _readScrollController,
                    readOnly: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(24),
                    ),
                  ),
                ),
              ),
            ),
            if (showToolbar)
              Positioned(
                top: _toolbarBelow
                    ? _toolbarOffset.dy + 8
                    : _toolbarOffset.dy - 140,
                left: (_toolbarOffset.dx - 155).clamp(0, double.infinity),
                child: Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: GestureDetector(
                    onTap: () => _readFocusNode.requestFocus(),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: _buildAnnotationToolbar(),
                    ),
                  ),
                ),
              ),
            if (_showInlineSearch && _searchMatches.isNotEmpty)
              CustomPaint(
                painter: SearchHighlightPainter(
                  matches: _searchMatches,
                  currentIndex: _currentSearchIndex,
                  areaKey: _readAreaKey,
                  scrollController: _readScrollController,
                  textController: _readController,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onReadSelectionChanged() {
    final sel = _readController.selection;
    final wasActive = _selectionActive;
    final nowActive = sel.isValid && !sel.isCollapsed;

    if (nowActive) {
      _updateActiveFromSelection(sel.start, sel.end);
      _recalcToolbarPosition();
    } else {
      setState(() => _typeLocked = false);
    }

    if (wasActive != nowActive) {
      setState(() => _selectionActive = nowActive);
    }
  }

  void _recalcToolbarPosition() {
    final sel = _readController.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final renderEditable = _cachedRenderEditable;
    if (renderEditable == null || !renderEditable.attached) {
      final areaBox =
          _readAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (areaBox != null) {
        _cachedRenderEditable = findRenderEditable(areaBox);
      }
    }
    final re = _cachedRenderEditable;
    if (re == null) return;

    try {
      final boxes = re.getBoxesForSelection(sel);
      if (boxes.isEmpty) return;

      final firstBox = boxes.first;
      final lastBox = boxes.last;
      final globalOrigin = re.localToGlobal(Offset.zero);
      final areaBox =
          _readAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (areaBox == null) return;
      final areaOrigin = areaBox.localToGlobal(Offset.zero);
      final relativeOrigin = globalOrigin - areaOrigin;

      final selTop = relativeOrigin.dy + firstBox.top;
      final selBottom = relativeOrigin.dy + lastBox.bottom;
      final selMidX = relativeOrigin.dx + (firstBox.left + lastBox.right) / 2;
      final areaHeight = areaBox.size.height;

      _toolbarBelow = selTop < areaHeight / 2;
      _toolbarOffset = Offset(selMidX, _toolbarBelow ? selBottom : selTop);
    } catch (_) {}
  }

  Widget _buildAnnotationToolbar() {
    final configAsync = ref.watch(userConfigProvider);
    final colors = configAsync.whenOrNull(
          data: (config) => config.annotationColorsHex,
        ) ??
        const [
          'FF5252',
          'FF9800',
          'FFEB3B',
          '4CAF50',
          '2196F3',
          '3F51B5',
          '9C27B0',
        ];

    return Container(
      width: 310,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTypeButton(
                AnnotationType.underline,
                Icons.format_underline,
                '下划线',
              ),
              _buildTypeButton(
                AnnotationType.strikethrough,
                Icons.strikethrough_s,
                '删除线',
              ),
              _buildTypeButton(
                AnnotationType.highlight,
                Icons.format_color_fill,
                '涂色',
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildClearButton(),
              ...colors.map((hex) {
                final color = Color(int.parse('FF$hex', radix: 16));
                final isActive = _activeColor == hex;
                return GestureDetector(
                  onTap: () => _applyColor(hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isActive
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(AnnotationType type, IconData icon, String tooltip) {
    final isActive = _activeType == type;
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _activeType = type;
              _typeLocked = true;
            });
            final sel = _readController.selection;
            if (sel.isValid && !sel.isCollapsed) {
              _updateActiveColorFromSelection(sel.start, sel.end);
            }
            _readFocusNode.requestFocus();
          },
          child: Container(
            width: 44,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '清除标记',
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _clearActiveAnnotation,
          child: Container(
            width: 44,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
            ),
            child: Icon(Icons.close, size: 22, color: scheme.error),
          ),
        ),
      ),
    );
  }

  void _updateActiveFromSelection(int start, int end) {
    setState(() {
      final annotations = _readController.annotations
          .where((a) => a.startOffset < end && a.endOffset > start)
          .toList();

      if (annotations.isEmpty) {
        _activeType = AnnotationType.underline;
        _activeColor = null;
        _typeLocked = false;
        return;
      }

      if (!_typeLocked) {
        final typeCount = <AnnotationType, int>{};
        for (final a in annotations) {
          typeCount[a.type] = (typeCount[a.type] ?? 0) + 1;
        }
        _activeType = _pickMostFrequentType(typeCount);
      }

      final sameTypeAnnotations = annotations
          .where((a) => a.type == _activeType)
          .toList();
      final colorCount = <String, int>{};
      for (final a in sameTypeAnnotations) {
        if (a.colorHex != null) {
          colorCount[a.colorHex!] = (colorCount[a.colorHex!] ?? 0) + 1;
        }
      }
      _activeColor = colorCount.isEmpty
          ? null
          : _pickMostFrequentColor(colorCount);
    });
  }

  void _updateActiveColorFromSelection(int start, int end) {
    final annotations = _readController.annotations
        .where(
          (a) =>
              a.type == _activeType &&
              a.startOffset < end &&
              a.endOffset > start,
        )
        .toList();
    final colorCount = <String, int>{};
    for (final a in annotations) {
      if (a.colorHex != null) {
        colorCount[a.colorHex!] = (colorCount[a.colorHex!] ?? 0) + 1;
      }
    }
    setState(() {
      _activeColor = colorCount.isEmpty
          ? null
          : _pickMostFrequentColor(colorCount);
    });
  }

  AnnotationType _pickMostFrequentType(Map<AnnotationType, int> counts) {
    final candidates = annotationTypeOrder
        .where((t) => counts.containsKey(t))
        .toList();
    if (candidates.isEmpty) return AnnotationType.underline;
    candidates.sort((a, b) {
      final diff = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (diff != 0) return diff;
      return annotationTypeOrder
          .indexOf(a)
          .compareTo(annotationTypeOrder.indexOf(b));
    });
    return candidates.first;
  }

  String _pickMostFrequentColor(Map<String, int> counts) {
    final configAsync = ref.read(userConfigProvider);
    final colors = configAsync.whenOrNull(
          data: (config) => config.annotationColorsHex,
        ) ??
        const [
          'FF5252',
          'FF9800',
          'FFEB3B',
          '4CAF50',
          '2196F3',
          '3F51B5',
          '9C27B0',
        ];

    final candidates = colors.where((c) => counts.containsKey(c)).toList();
    if (candidates.isEmpty) return colors.first;
    candidates.sort((a, b) {
      final diff = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (diff != 0) return diff;
      return colors.indexOf(a).compareTo(colors.indexOf(b));
    });
    return candidates.first;
  }

  void _applyColor(String colorHex) {
    final sel = _readController.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final start = sel.start;
    final end = sel.end;

    _readController.annotations = _readController.annotations.expand((a) {
      if (a.type != _activeType) return [a];
      if (a.endOffset <= start || a.startOffset >= end) return [a];
      final split = <Annotation>[];
      if (a.startOffset < start) {
        split.add(a.copyWith(endOffset: start));
      }
      if (a.endOffset > end) {
        split.add(a.copyWith(startOffset: end));
      }
      return split;
    }).toList();

    _readController.annotations.add(
      Annotation(
        id: _uuid.v4(),
        type: _activeType,
        colorHex: colorHex,
        startOffset: start,
        endOffset: end,
      ),
    );

    setState(() => _activeColor = colorHex);
    _readController.rebuildText();
    _readFocusNode.requestFocus();
    _onAnnotationsChanged();
  }

  void _clearActiveAnnotation() {
    final sel = _readController.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final start = sel.start;
    final end = sel.end;

    _readController.annotations = _readController.annotations.expand((a) {
      if (a.type != _activeType) return [a];
      if (a.endOffset <= start || a.startOffset >= end) return [a];
      final split = <Annotation>[];
      if (a.startOffset < start) {
        split.add(a.copyWith(endOffset: start));
      }
      if (a.endOffset > end) {
        split.add(a.copyWith(startOffset: end));
      }
      return split;
    }).toList();

    setState(() => _activeColor = null);
    _readController.rebuildText();
    _readFocusNode.requestFocus();
    _onAnnotationsChanged();
  }

  // ==================== 空状态 / 书籍信息 ====================

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo(String bookId, WidgetRef ref) {
    final book = ref.watch(currentBookProvider);
    if (book == null) return _buildEmptyState('加载中...');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            book.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (book.author.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '作者: ${book.author}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
          const SizedBox(height: 24),
          const Text('请在左侧选择一个章节开始编辑', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

