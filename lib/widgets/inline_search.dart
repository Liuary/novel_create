import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'search_util.dart';

enum SearchMode { search, replace }

class InlineSearchOverlay extends StatefulWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final GlobalKey textAreaKey;
  final String? initialQuery;
  final VoidCallback onClose;
  final TextStyle? textStyle;
  final void Function(List<SearchMatch> matches, String query, int currentIndex)?
      onMatchesChanged;

  const InlineSearchOverlay({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.textAreaKey,
    this.initialQuery,
    required this.onClose,
    this.textStyle,
    this.onMatchesChanged,
  });

  @override
  State<InlineSearchOverlay> createState() => _InlineSearchOverlayState();
}

class _InlineSearchOverlayState extends State<InlineSearchOverlay> {
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  final _searchFocus = FocusNode();
  SearchMode _mode = SearchMode.search;
  List<SearchMatch> _matches = [];
  int _currentMatchIndex = -1;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _matches = [];
        _currentMatchIndex = -1;
        _hasSearched = true;
      });
      return;
    }
    final text = widget.controller.text;
    final matches = findAllMatches(text, query);
    setState(() {
      _matches = matches;
      _hasSearched = true;
      if (matches.isNotEmpty) {
        _currentMatchIndex = 0;
        _scrollToMatch(0);
      } else {
        _currentMatchIndex = -1;
      }
    });
    widget.onMatchesChanged?.call(matches, query, _currentMatchIndex);
    widget.controller.selection = TextSelection.collapsed(offset: -1);
    widget.controller.value = widget.controller.value; // 触发重绘高亮
  }

  void _scrollToMatch(int index) {
    if (index < 0 || index >= _matches.length) return;
    final match = _matches[index];

    widget.controller.selection =
        TextSelection(baseOffset: match.start, extentOffset: match.end);

    if (!widget.scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final areaBox =
          widget.textAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (areaBox == null || !areaBox.attached) return;

      final re = _findRenderEditable(areaBox);
      if (re == null || !re.attached) return;

      try {
        final boxes = re.getBoxesForSelection(
          TextSelection(baseOffset: match.start, extentOffset: match.end),
        );
        if (boxes.isEmpty) return;

        final firstBox = boxes.first;
        final reGlobal = re.localToGlobal(Offset.zero);
        final areaGlobal = areaBox.localToGlobal(Offset.zero);
        final relativeOrigin = reGlobal - areaGlobal;

        final lineHeight = re.preferredLineHeight;
        final scrollOffset = widget.scrollController.offset;
        final textPainterTop = firstBox.top + scrollOffset;
        final lineIndex = (textPainterTop / lineHeight).round();
        final matchTop = lineIndex * lineHeight - scrollOffset + relativeOrigin.dy;

        final viewport = widget.scrollController.position.viewportDimension;
        final maxScroll = widget.scrollController.position.maxScrollExtent;
        final targetScroll =
            (widget.scrollController.offset + matchTop - viewport * 0.3)
                .clamp(0.0, maxScroll);

        widget.scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (_) {}
    });
  }

  static RenderEditable? _findRenderEditable(RenderObject root) {
    if (root is RenderEditable) return root;
    RenderEditable? found;
    root.visitChildren((child) {
      found ??= _findRenderEditable(child);
    });
    return found;
  }

  void _navigateNext() {
    if (_matches.isEmpty) return;
    final next =
        (_currentMatchIndex + 1) % _matches.length;
    setState(() => _currentMatchIndex = next);
    _scrollToMatch(next);
    widget.onMatchesChanged
        ?.call(_matches, _searchController.text, next);
  }

  void _navigatePrev() {
    if (_matches.isEmpty) return;
    final prev = (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    setState(() => _currentMatchIndex = prev);
    _scrollToMatch(prev);
    widget.onMatchesChanged
        ?.call(_matches, _searchController.text, prev);
  }

  void _replaceCurrent() {
    if (_currentMatchIndex < 0 || _currentMatchIndex >= _matches.length) return;
    final match = _matches[_currentMatchIndex];
    final text = widget.controller.text;
    final replacement = _replaceController.text;
    final newText = text.substring(0, match.start) +
        replacement +
        text.substring(match.end);
    final cursorOffset = match.start + replacement.length;

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(offset: cursorOffset);

    _performSearch();
  }

  void _replaceAll() {
    if (_matches.isEmpty) return;
    final text = widget.controller.text;
    final query = _searchController.text;
    final replacement = _replaceController.text;

    final newText = text.replaceAll(
        RegExp(RegExp.escape(query), caseSensitive: false), replacement);

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(offset: newText.length);

    _performSearch();

    setState(() {
      _matches = [];
      _currentMatchIndex = -1;
      _hasSearched = true;
    });
    widget.onMatchesChanged?.call([], '', -1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchCount = _matches.length;
    final matchLabel = _hasSearched
        ? (matchCount > 0 ? '${_currentMatchIndex + 1}/$matchCount' : '0/0')
        : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
            bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  autofocus: widget.initialQuery == null,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4)),
                    hintText: _mode == SearchMode.search ? '搜索...' : '查找...',
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              if (_mode == SearchMode.replace) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _replaceController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4)),
                      hintText: '替换为...',
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              _buildSmallButton(
                Icons.search,
                '搜索',
                _performSearch,
                compact: true,
              ),
              const SizedBox(width: 4),
              _buildModeDropdown(theme),
              const SizedBox(width: 4),
              _buildSmallButton(Icons.close, '关闭', widget.onClose,
                  compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildNavButton(Icons.chevron_left, _navigatePrev,
                  enabled: _matches.isNotEmpty),
              const SizedBox(width: 4),
              SizedBox(
                width: 48,
                child: Text(
                  matchLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: _hasSearched && matchCount == 0
                          ? theme.colorScheme.error
                          : null),
                ),
              ),
              const SizedBox(width: 4),
              _buildNavButton(Icons.chevron_right, _navigateNext,
                  enabled: _matches.isNotEmpty),
              const Spacer(),
              if (_mode == SearchMode.replace) ...[
                _buildSmallButton(
                    Icons.find_replace, '替换全部', _replaceAll),
                const SizedBox(width: 6),
                _buildSmallButton(
                  Icons.swap_horiz,
                  '替换',
                  _replaceCurrent,
                  enabled: _currentMatchIndex >= 0,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeDropdown(ThemeData theme) {
    return PopupMenuButton<SearchMode>(
      initialValue: _mode,
      tooltip: '搜索/替换',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
      icon: const Icon(Icons.tune, size: 16),
      onSelected: (m) {
        setState(() => _mode = m);
        if (m == SearchMode.search) {
          _replaceController.clear();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SearchMode.search,
          child: Row(children: [
            Icon(Icons.search, size: 16),
            SizedBox(width: 8),
            Text('搜索'),
          ]),
        ),
        const PopupMenuItem(
          value: SearchMode.replace,
          child: Row(children: [
            Icon(Icons.find_replace, size: 16),
            SizedBox(width: 8),
            Text('替换'),
          ]),
        ),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String tooltip, VoidCallback onTap,
      {bool compact = false, bool enabled = true}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: BoxConstraints(
                minWidth: compact ? 28 : 32,
                minHeight: compact ? 28 : 32),
            alignment: Alignment.center,
            child: Icon(icon,
                size: compact ? 16 : 18,
                color: enabled ? null : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap,
      {bool enabled = true}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.zero,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
