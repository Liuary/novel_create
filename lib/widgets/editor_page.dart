import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chapter.dart';
import '../models/annotation.dart';
import '../providers/app_providers.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

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
  bool _isReadingMode = false;
  bool _isLoading = false;
  Chapter? _currentChapter;

  bool _isEditingTitle = false;

  AnnotationType _activeType = AnnotationType.underline;
  String? _activeColor;

  bool _selectionActive = false;
  Offset _toolbarOffset = Offset.zero;
  bool _toolbarBelow = true;

  int _wordCount = 0;
  final _readAreaKey = GlobalKey();
  RenderEditable? _cachedRenderEditable;

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
    _readController.addListener(_onReadSelectionChanged);
  }

  @override
  void dispose() {
    _writeController.removeListener(_updateWordCount);
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
    setState(() => _wordCount = chars);
  }

  // ==================== 加载章节 ====================

  @override
  Widget build(BuildContext context) {
    final bookId = ref.watch(currentBookIdProvider);
    final volumeId = ref.watch(currentVolumeIdProvider);
    final chapterId = ref.watch(currentChapterIdProvider);

    if (bookId == null) {
      return _buildEmptyState('请先在左侧创建或选择一本书籍');
    }
    if (chapterId == null) {
      return _buildBookInfo(bookId, ref);
    }
    if (_loadedChapterId != chapterId) {
      _loadChapter(bookId, volumeId!, chapterId);
    }
    if (_isLoading || _currentChapter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildTitleBar(),
        Expanded(child: _isReadingMode ? _buildReadingMode() : _buildWritingMode()),
      ],
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: Text(title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            tooltip: '保存',
            onPressed: _saveCurrentChapter,
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
      _readController.annotations = List.from(_currentChapter?.annotations ?? []);
    }
    setState(() {
      _isReadingMode = toReading;
      _activeType = AnnotationType.underline;
      _activeColor = null;
      _selectionActive = false;
    });
    _updateWordCount();
  }

  // ==================== 写作模式 ====================

  Widget _buildWritingMode() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Scrollbar(
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(24),
              hintText: '开始创作...',
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 阅读模式 ====================

  Widget _buildReadingMode() {
    final hasSelection = _readController.selection.isValid &&
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
        child: Scrollbar(
          controller: _readScrollController,
          thumbVisibility: true,
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thickness: WidgetStateProperty.all(0.0),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
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
              ],
            ),
          ),
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
      _toolbarOffset = Offset(
        selMidX,
        _toolbarBelow ? selBottom : selTop,
      );
    } catch (_) {
      // 计算失败时使用默认位置
    }
  }

  Widget _buildAnnotationToolbar() {
    final colors = annotationColorsHex;
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
          // 上层：下划线、删除线、涂色
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTypeButton(AnnotationType.underline, Icons.format_underline, '下划线'),
              _buildTypeButton(AnnotationType.strikethrough, Icons.strikethrough_s, '删除线'),
              _buildTypeButton(AnnotationType.highlight, Icons.format_color_fill, '涂色'),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          // 下层：清除 + 7颜色
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
                        ? Icon(Icons.check, size: 14,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white)
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
            setState(() => _activeType = type);
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
            child: Icon(icon, size: 22,
                color: isActive ? scheme.primary : scheme.onSurfaceVariant),
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
        return;
      }

      // 统计最多类型
      final typeCount = <AnnotationType, int>{};
      for (final a in annotations) {
        typeCount[a.type] = (typeCount[a.type] ?? 0) + 1;
      }
      _activeType = _pickMostFrequentType(typeCount);

      // 统计该类型下最多颜色
      final sameTypeAnnotations = annotations.where((a) => a.type == _activeType).toList();
      final colorCount = <String, int>{};
      for (final a in sameTypeAnnotations) {
        if (a.colorHex != null) {
          colorCount[a.colorHex!] = (colorCount[a.colorHex!] ?? 0) + 1;
        }
      }
      _activeColor = colorCount.isEmpty ? null : _pickMostFrequentColor(colorCount);
    });
  }

  void _updateActiveColorFromSelection(int start, int end) {
    final annotations = _readController.annotations
        .where((a) => a.type == _activeType && a.startOffset < end && a.endOffset > start)
        .toList();
    final colorCount = <String, int>{};
    for (final a in annotations) {
      if (a.colorHex != null) {
        colorCount[a.colorHex!] = (colorCount[a.colorHex!] ?? 0) + 1;
      }
    }
    setState(() {
      _activeColor = colorCount.isEmpty ? null : _pickMostFrequentColor(colorCount);
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
      return annotationTypeOrder.indexOf(a).compareTo(annotationTypeOrder.indexOf(b));
    });
    return candidates.first;
  }

  String _pickMostFrequentColor(Map<String, int> counts) {
    final candidates = annotationColorsHex
        .where((c) => counts.containsKey(c))
        .toList();
    if (candidates.isEmpty) return annotationColorsHex.first;
    candidates.sort((a, b) {
      final diff = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (diff != 0) return diff;
      return annotationColorsHex.indexOf(a).compareTo(annotationColorsHex.indexOf(b));
    });
    return candidates.first;
  }

  void _applyColor(String colorHex) {
    final sel = _readController.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final start = sel.start;
    final end = sel.end;

    // 删除同类型的重叠标记
    _readController.annotations.removeWhere((a) =>
        a.type == _activeType && a.startOffset < end && a.endOffset > start);
    // 截断相交的标记
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
    // 添加新标记
    _readController.annotations.add(Annotation(
      id: _uuid.v4(),
      type: _activeType,
      colorHex: colorHex,
      startOffset: start,
      endOffset: end,
    ));

    setState(() => _activeColor = colorHex);
    _readController._rebuildText();
    _readFocusNode.requestFocus();
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
  }

  // ==================== 保存 ====================

  Future<void> _saveCurrentChapter() async {
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), duration: Duration(seconds: 1)),
      );
    }
  }

  // ==================== 加载章节 ====================

  Future<void> _loadChapter(String bookId, String volumeId, String chapterId) async {
    setState(() => _isLoading = true);
    final storage = StorageService.instance;
    final chapter = await storage.loadChapter(bookId, volumeId, chapterId);
    if (chapter != null) {
      _writeController.text = chapter.content;
      _readController.text = chapter.content;
      _readController.annotations = List.from(chapter.annotations);
      _currentChapter = chapter;
    }
    _loadedChapterId = chapterId;
    _isReadingMode = false;
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
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
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
          Text(book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (book.author.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('作者: ${book.author}',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
          const SizedBox(height: 24),
          const Text('请在左侧选择一个章节开始编辑',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

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
    final color = isActive ? scheme.primary : scheme.onSurface.withValues(alpha: 0.4);
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
    final segments = _buildSegments(text);
    return TextSpan(
      children: segments.map((seg) {
        TextStyle s = style ?? const TextStyle();
        if (seg.hasUnderline) {
          s = s.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: seg.underlineColor,
          );
        }
        if (seg.hasStrikethrough) {
          s = s.copyWith(
            decoration: s.decoration != null
                ? TextDecoration.combine([s.decoration!, TextDecoration.lineThrough])
                : TextDecoration.lineThrough,
            decorationColor: seg.strikethroughColor,
          );
        }
        if (seg.hasHighlight) {
          s = s.copyWith(backgroundColor: seg.highlightColor);
        }
        return TextSpan(text: seg.text, style: s);
      }).toList(),
      style: style,
    );
  }

  List<_TextSegment> _buildSegments(String text) {
    // 收集所有断点
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

      segments.add(_TextSegment(
        text: segText,
        hasUnderline: ulColor != null,
        underlineColor: ulColor != null ? Color(int.parse('FF$ulColor', radix: 16)) : null,
        hasStrikethrough: stColor != null,
        strikethroughColor: stColor != null ? Color(int.parse('FF$stColor', radix: 16)) : null,
        hasHighlight: hlColor != null,
        highlightColor: hlColor != null ? Color(int.parse('FF$hlColor', radix: 16)) : null,
      ));
    }
    return segments;
  }

  void _rebuildText() {
    // 重建文本：保持当前文字不变，但重绘标注
    final oldText = text;
    value = TextEditingValue(
      text: oldText,
      selection: selection,
    );
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
}
