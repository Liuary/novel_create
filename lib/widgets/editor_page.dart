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

  final _readController = _AnnotatedTextController();
  final _readScrollController = ScrollController();
  final _readFocusNode = FocusNode();

  final _titleController = TextEditingController();

  String? _loadedChapterId;
  String? _loadedVolumeId;
  String? _loadedBookId;
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

  Timer? _countdownTimer;
  String _savedContent = '';
  String _savedAnnotationsJson = '';
  bool _hasUnsavedChanges = false;
  String _autoSaveStatus = '';
  int _autoSaveCountdown = -1;
  bool _isChangingChapter = false;
  bool _onChapterChangingGuard = false;
  bool _saveCallbackRegistered = false;

  RenderEditable? _findRenderEditable(RenderObject root) {
    if (root is RenderEditable) return root;
    RenderEditable? found;
    root.visitChildren((child) {
      found ??= _findRenderEditable(child);
    });
    return found;
  }

  @override
  void initState() {
    super.initState();
    _writeController.addListener(_updateWordCount);
    _writeController.addListener(_markWriteDirty);
    _readController.addListener(_onReadSelectionChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCurrentChapter();
    });
  }

  @override
  void deactivate() {
    ref.read(onExitSaveProvider.notifier).state = null;
    super.deactivate();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _writeController.removeListener(_updateWordCount);
    _writeController.removeListener(_markWriteDirty);
    _writeController.dispose();
    _writeScrollController.dispose();
    _writeFocusNode.dispose();
    _readController.dispose();
    _readScrollController.dispose();
    _readFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _isReadingMode ? _readController.text : _writeController.text;
    final chars = text.replaceAll(RegExp(r'\s'), '').length;
    if (chars != _wordCount) {
      setState(() => _wordCount = chars);
    }
  }

  void _markWriteDirty() {
    _checkDirty();
    if (_hasUnsavedChanges) {
      _resetAutoSaveCountdown();
    }
  }

  void _markAnnotationsDirty() {
    _checkDirty();
    if (_hasUnsavedChanges) {
      _resetAutoSaveCountdown();
    }
  }

  void _clearDirty() {
    _hasUnsavedChanges = false;
    _savedContent = _writeController.text;
    _savedAnnotationsJson = _readController.annotations.toString();
    ref.read(hasUnsavedChangesProvider.notifier).state = false;
  }

  void _checkDirty() {
    final textDirty = _isReadingMode
        ? false
        : _writeController.text != _savedContent;
    final annotationDirty = _isReadingMode
        ? _readController.annotations.toString() != _savedAnnotationsJson
        : false;
    final isDirty = textDirty || annotationDirty;
    if (isDirty != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = isDirty);
      ref.read(hasUnsavedChangesProvider.notifier).state = isDirty;
      if (!isDirty) {
        _autoSaveCountdown = -1;
        setState(() => _autoSaveStatus = '');
        _countdownTimer?.cancel();
        _startAutoSaveTimer();
      }
    }
  }

  void _startAutoSaveTimer() {
    _countdownTimer?.cancel();
    _autoSaveCountdown = -1;
    setState(() => _autoSaveStatus = '');
    final configAsync = ref.read(userConfigProvider);
    configAsync.whenData((config) {
      final interval = config.autoSaveIntervalSeconds;
      _autoSaveCountdown = interval;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_hasUnsavedChanges) {
          _autoSaveCountdown--;
          if (_autoSaveCountdown <= 0) {
            _autoSaveCountdown = 0;
            _autoSave();
          } else {
            setState(() => _autoSaveStatus = '自动保存 ${_autoSaveCountdown}s');
          }
        } else {
          if (_autoSaveCountdown != interval) {
            _autoSaveCountdown = interval;
            setState(() => _autoSaveStatus = '');
          }
        }
      });
    });
  }

  void _resetAutoSaveCountdown() {
    final interval = ref.read(userConfigProvider).whenOrNull(
          data: (c) => c.autoSaveIntervalSeconds,
        ) ?? 10;
    _autoSaveCountdown = interval;
    setState(() {});
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;
    await _saveCurrentChapter(silent: true);
    _autoSaveCountdown = ref.read(userConfigProvider).whenOrNull(
          data: (c) => c.autoSaveIntervalSeconds,
        ) ?? 10;
    if (mounted) {
      setState(() => _autoSaveStatus = '');
      ref.read(toastProvider.notifier).show('自动保存成功');
    }
  }

  Future<void> _loadCurrentChapter() async {
    if (!mounted) return;
    final bookId = ref.read(currentBookIdProvider);
    final volumeId = ref.read(currentVolumeIdProvider);
    final chapterId = ref.read(currentChapterIdProvider);
    if (bookId == null || volumeId == null || chapterId == null) return;
    await _loadChapter(bookId, volumeId, chapterId);
  }

  // ==================== 章节切换（未保存检测） ====================

  void _onChapterChanging(String newChapterId) {
    if (_isChangingChapter || _onChapterChangingGuard) return;
    _onChapterChangingGuard = true;
    if (_hasUnsavedChanges && _loadedChapterId != null) {
      ref.read(currentChapterIdProvider.notifier).state = _loadedChapterId;
      _showUnsavedDialog(
        onSave: () async {
          await _saveCurrentChapter(silent: true);
          if (!mounted) return;
          _isChangingChapter = false;
          _onChapterChangingGuard = false;
          ref.read(currentChapterIdProvider.notifier).state = newChapterId;
          _loadCurrentChapter();
        },
        onDiscard: () {
          if (!mounted) return;
          _clearDirty();
          _isChangingChapter = false;
          _onChapterChangingGuard = false;
          ref.read(currentChapterIdProvider.notifier).state = newChapterId;
          _loadCurrentChapter();
        },
        onCancel: () {
          _isChangingChapter = false;
          _onChapterChangingGuard = false;
          _restoreProviderState();
        },
      );
    } else {
      if (!mounted) return;
      _isChangingChapter = false;
      _onChapterChangingGuard = false;
      _loadCurrentChapter();
    }
  }

  void _restoreProviderState() {
    _isChangingChapter = true;
    _onChapterChangingGuard = true;
    ref.read(currentBookIdProvider.notifier).state = _loadedBookId;
    ref.read(currentVolumeIdProvider.notifier).state = _loadedVolumeId;
    ref.read(currentChapterIdProvider.notifier).state = _loadedChapterId;
    Future.microtask(() {
      _isChangingChapter = false;
      _onChapterChangingGuard = false;
    });
  }

  void _onLeavingChapter() {
    if (_isChangingChapter || _onChapterChangingGuard) return;
    _onChapterChangingGuard = true;
    _showUnsavedDialog(
      onSave: () async {
        await _saveCurrentChapter(silent: true);
        _isChangingChapter = false;
        _onChapterChangingGuard = false;
        ref.read(currentChapterIdProvider.notifier).state = null;
        ref.read(currentVolumeIdProvider.notifier).state = null;
        ref.read(currentBookIdProvider.notifier).state = null;
        _clearChapterState();
      },
      onDiscard: () {
        _clearDirty();
        _isChangingChapter = false;
        _onChapterChangingGuard = false;
        ref.read(currentChapterIdProvider.notifier).state = null;
        ref.read(currentVolumeIdProvider.notifier).state = null;
        ref.read(currentBookIdProvider.notifier).state = null;
        _clearChapterState();
      },
      onCancel: () {
        _isChangingChapter = false;
        _onChapterChangingGuard = false;
        _restoreProviderState();
      },
    );
  }

  Future<void> _showUnsavedDialog({
    required Future<void> Function() onSave,
    required VoidCallback onDiscard,
    required VoidCallback onCancel,
  }) async {
    _isChangingChapter = true;
    final action = await showDialog<_SaveDialogAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('未保存的更改'),
        content: const Text('当前章节有未保存的编辑内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_SaveDialogAction.cancel),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_SaveDialogAction.discard),
            child: const Text('放弃'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_SaveDialogAction.save),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    switch (action) {
      case _SaveDialogAction.save:
        await onSave();
      case _SaveDialogAction.discard:
        onDiscard();
      case _SaveDialogAction.cancel:
      case null:
        onCancel();
    }
  }

  void _clearChapterState() {
    _writeController.text = '';
    _readController.text = '';
    _readController.annotations = [];
    _currentChapter = null;
    _loadedChapterId = null;
    _loadedVolumeId = null;
    _loadedBookId = null;
    _clearDirty();
    _autoSaveStatus = '';
    _autoSaveCountdown = -1;
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    ref.listen(currentChapterIdProvider, (prev, next) {
      if (!mounted) return;
      if (prev != next && next != null && !_isChangingChapter) {
        _onChapterChanging(next);
      } else if (prev != null && next == null && _hasUnsavedChanges && !_isChangingChapter) {
        _onLeavingChapter();
      }
    });
    ref.listen(currentVolumeIdProvider, (prev, next) {
      if (!mounted) return;
      if (prev != null && next == null && _hasUnsavedChanges && _loadedChapterId != null && !_isChangingChapter) {
        _onLeavingChapter();
      }
    });
    ref.listen(currentBookIdProvider, (prev, next) {
      if (!mounted) return;
      if (prev != null && next == null && _hasUnsavedChanges && _loadedChapterId != null && !_isChangingChapter) {
        _onLeavingChapter();
      }
    });
    if (!_saveCallbackRegistered) {
      _saveCallbackRegistered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(onExitSaveProvider.notifier).state = _saveCurrentChapter;
        }
      });
    }
    if (_countdownTimer == null && _currentChapter != null) {
      _startAutoSaveTimer();
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
          _ModeButton(
            icon: Icons.edit,
            label: '写作',
            isActive: !_isReadingMode,
            onPressed: () => _switchMode(false),
          ),
          _ModeButton(
            icon: Icons.visibility,
            label: '阅读',
            isActive: _isReadingMode,
            onPressed: () => _switchMode(true),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存 (Ctrl+S)',
            onPressed: _hasUnsavedChanges ? _saveCurrentChapter : null,
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
    _checkDirty();
  }

  // ==================== 写作模式 ====================

  Widget _buildWritingMode() {
    return Container(
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
          _buildAutoSaveNotification(),
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
              painter: _DecorationPainter(
                annotations: _readController.annotations,
                areaKey: _readAreaKey,
                scrollController: _readScrollController,
                textController: _readController,
                drawHighlights: true,
                drawStrikethroughs: false,
              ),
              foregroundPainter: _DecorationPainter(
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
                _buildAutoSaveNotification(),
              ],
            ),
          ),
        );
  }

  Widget _buildAutoSaveNotification() {
    if (_autoSaveStatus.isEmpty) return const SizedBox.shrink();
    return Positioned(
      left: 24,
      bottom: 24,
      child: Text(
        _autoSaveStatus,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          shadows: [
            Shadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.8),
              blurRadius: 2,
            ),
            Shadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.6),
              blurRadius: 4,
              offset: const Offset(0, 1),
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
        _cachedRenderEditable = _findRenderEditable(areaBox);
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
    } catch (_) {
    }
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
    _readController._rebuildText();
    _readFocusNode.requestFocus();
    _markAnnotationsDirty();
    _autoSaveAnnotations();
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
    _readController._rebuildText();
    _readFocusNode.requestFocus();
    _markAnnotationsDirty();
    _autoSaveAnnotations();
  }

  void _autoSaveAnnotations() {
    _currentChapter?.annotations = List.from(_readController.annotations);
    _saveCurrentChapter(silent: true);
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

    if (!silent && mounted) {
      ref.read(toastProvider.notifier).show('保存成功');
    }
  }

  // ==================== 加载章节 ====================

  Future<void> _loadChapter(
    String bookId,
    String volumeId,
    String chapterId,
  ) async {
    setState(() => _isLoading = true);
    final storage = StorageService.instance;
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);
    _loadedChapterId = chapterId;
    _loadedVolumeId = volumeId;
    _loadedBookId = bookId;

    _savedContent = chapter?.content ?? '';
    _savedAnnotationsJson = (chapter?.annotations ?? []).toString();

    if (chapter != null) {
      _writeController.text = chapter.content;
      _readController.text = chapter.content;
      _readController.annotations = List.from(chapter.annotations);
      _currentChapter = chapter;
    }
    _isReadingMode = false;
    _hasUnsavedChanges = false;
    ref.read(hasUnsavedChangesProvider.notifier).state = false;
    _autoSaveStatus = '';
    _autoSaveCountdown = -1;
    _startAutoSaveTimer();
    setState(() => _isLoading = false);
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

enum _SaveDialogAction { save, discard, cancel }

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isActive
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.4);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ==================== 自定义 TextEditingController（阅读模式渲染标注） ====================

class _AnnotatedTextController extends TextEditingController {
  List<Annotation> annotations = [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(text: '', style: style);
    }
    final baseStyle = (style ?? const TextStyle(fontSize: 16)).copyWith(
      height: 1.6,
    );
    final segments = _buildSegments(text);

    final merged = <_TextSegment>[];
    for (final seg in segments) {
      if (merged.isNotEmpty && merged.last.styleEquals(seg)) {
        merged.last = merged.last.mergedWith(seg);
      } else {
        merged.add(seg);
      }
    }

    return TextSpan(
      style: baseStyle,
      children: merged.map((seg) {
        TextStyle s = baseStyle;
        if (seg.hasUnderline) {
          s = s.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: seg.underlineColor,
          );
        }
        return TextSpan(text: seg.text, style: s);
      }).toList(),
    );
  }

  List<_TextSegment> _buildSegments(String text) {
    final breakpoints = <int>{0, text.length};
    for (final a in annotations) {
      if (a.startOffset >= 0 && a.startOffset <= text.length) {
        breakpoints.add(a.startOffset);
      }
      if (a.endOffset >= 0 && a.endOffset <= text.length) {
        breakpoints.add(a.endOffset);
      }
    }
    final sorted = breakpoints.toList()..sort();

    final segments = <_TextSegment>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      final start = sorted[i];
      final end = sorted[i + 1];
      if (start >= end) continue;

      final segText = text.substring(start, end);
      String? ulColor;
      String? stColor;
      String? hlColor;

      for (final a in annotations) {
        if (a.startOffset <= start && a.endOffset >= end) {
          switch (a.type) {
            case AnnotationType.underline:
              ulColor = a.colorHex;
            case AnnotationType.strikethrough:
              stColor = a.colorHex;
            case AnnotationType.highlight:
              hlColor = a.colorHex;
          }
        }
      }

      segments.add(
        _TextSegment(
          text: segText,
          hasUnderline: ulColor != null,
          underlineColor: ulColor != null
              ? Color(int.parse('FF$ulColor', radix: 16))
              : null,
          hasStrikethrough: stColor != null,
          strikethroughColor: stColor != null
              ? Color(int.parse('FF$stColor', radix: 16))
              : null,
          hasHighlight: hlColor != null,
          highlightColor: hlColor != null
              ? Color(int.parse('FF$hlColor', radix: 16))
              : null,
        ),
      );
    }
    return segments;
  }

  void _rebuildText() {
    final oldText = text;
    value = TextEditingValue(text: oldText, selection: selection);
  }
}

class _TextSegment {
  final String text;
  final bool hasUnderline;
  final Color? underlineColor;
  final bool hasStrikethrough;
  final Color? strikethroughColor;
  final bool hasHighlight;
  final Color? highlightColor;

  const _TextSegment({
    required this.text,
    required this.hasUnderline,
    this.underlineColor,
    required this.hasStrikethrough,
    this.strikethroughColor,
    required this.hasHighlight,
    this.highlightColor,
  });

  bool styleEquals(_TextSegment other) =>
      hasUnderline == other.hasUnderline &&
      underlineColor == other.underlineColor &&
      hasStrikethrough == other.hasStrikethrough &&
      strikethroughColor == other.strikethroughColor &&
      hasHighlight == other.hasHighlight &&
      highlightColor == other.highlightColor;

  _TextSegment mergedWith(_TextSegment other) => _TextSegment(
        text: text + other.text,
        hasUnderline: hasUnderline,
        underlineColor: underlineColor,
        hasStrikethrough: hasStrikethrough,
        strikethroughColor: strikethroughColor,
        hasHighlight: hasHighlight,
        highlightColor: highlightColor,
      );
}

class _DecorationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final GlobalKey areaKey;
  final ScrollController scrollController;
  final TextEditingController textController;
  final bool drawHighlights;
  final bool drawStrikethroughs;

  _DecorationPainter({
    required this.annotations,
    required this.areaKey,
    required this.scrollController,
    required this.textController,
    required this.drawHighlights,
    required this.drawStrikethroughs,
  }) : super(repaint: Listenable.merge([scrollController, textController]));

  static RenderEditable? _findRenderEditable(RenderObject root) {
    if (root is RenderEditable) return root;
    RenderEditable? found;
    root.visitChildren((child) {
      found ??= _findRenderEditable(child);
    });
    return found;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final areaBox = areaKey.currentContext?.findRenderObject() as RenderBox?;
    if (areaBox == null || !areaBox.attached) return;

    final re = _findRenderEditable(areaBox);
    if (re == null || !re.attached) return;

    final reGlobal = re.localToGlobal(Offset.zero);
    final areaGlobal = areaBox.localToGlobal(Offset.zero);
    final reOffset = reGlobal - areaGlobal;

    final lineHeight = re.preferredLineHeight;
    final scrollOffset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;

    for (final annotation in annotations) {
      final isHighlight = annotation.type == AnnotationType.highlight;
      final isStrikethrough = annotation.type == AnnotationType.strikethrough;

      if (isHighlight && !drawHighlights) continue;
      if (isStrikethrough && !drawStrikethroughs) continue;
      if (!isHighlight && !isStrikethrough) continue;

      final selection = TextSelection(
        baseOffset: annotation.startOffset,
        extentOffset: annotation.endOffset,
      );

      final boxes = re.getBoxesForSelection(selection);
      if (boxes.isEmpty) continue;

      final color = Color(
        int.parse('FF${annotation.colorHex ?? "FFEB3B"}', radix: 16),
      );

      for (final box in boxes) {
        final textPainterTop = box.top + scrollOffset;
        final lineIndex = (textPainterTop / lineHeight).round();
        final normalizedTop = lineIndex * lineHeight - scrollOffset;
        final normalizedBottom = normalizedTop + lineHeight;

        final left = box.left + reOffset.dx;
        final right = box.right + reOffset.dx;
        final top = normalizedTop + reOffset.dy;
        final bottom = normalizedBottom + reOffset.dy;

        if (isHighlight) {
          final paint = Paint()..color = color.withValues(alpha: 0.3);
          canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
        } else if (isStrikethrough) {
          final paint = Paint()
            ..color = color
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round;
          final y = top + (bottom - top) * 0.55;
          canvas.drawLine(Offset(left, y), Offset(right, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DecorationPainter oldDelegate) {
    return annotations != oldDelegate.annotations ||
        drawHighlights != oldDelegate.drawHighlights ||
        drawStrikethroughs != oldDelegate.drawStrikethroughs;
  }
}
