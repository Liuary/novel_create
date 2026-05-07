import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/repositories/entity_link_repository.dart';
import '../outline_node_model.dart';
import '../outline_repository.dart';

class OutlineNodeEditor extends StatefulWidget {
  final String nodeId;
  final OutlineRepository repo;
  final EntityLinkRepository linkRepo;
  final String? currentChapterId;
  final ValueChanged<String> onTitleChanged;

  const OutlineNodeEditor({
    super.key,
    required this.nodeId,
    required this.repo,
    required this.linkRepo,
    this.currentChapterId,
    required this.onTitleChanged,
  });

  @override
  State<OutlineNodeEditor> createState() => OutlineNodeEditorState();
}

class OutlineNodeEditorState extends State<OutlineNodeEditor> {
  OutlineNode? _node;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _wordCountController = TextEditingController();
  String _type = 'free';
  String _status = 'planning';
  int _wordCount = 0;
  List<String>? _boundChapterIds;
  bool _isBound = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant OutlineNodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodeId != widget.nodeId) _load();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    _descController.dispose();
    _wordCountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final node = await widget.repo.getById(widget.nodeId);
    if (node == null) return;
    final links = await widget.linkRepo.findByFrom(
      fromType: 'outline_node',
      fromId: widget.nodeId,
    );
    if (!mounted) return;
    final chapterLinks = links.where((l) => l.toType == 'chapter');
    setState(() {
      _node = node;
      _titleController.text = node.title;
      _descController.text = node.description;
      _wordCountController.text = node.expectedWordCount.toString();
      _type = node.type;
      _status = node.status;
      _wordCount = node.expectedWordCount;
      _boundChapterIds = chapterLinks.map((l) => l.toId).toList();
      _isBound = widget.currentChapterId != null &&
          chapterLinks.any((l) => l.toId == widget.currentChapterId);
    });
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    if (_node == null) return;
    final updated = _node!.copyWith(
      title: _titleController.text,
      description: _descController.text,
      type: _type,
      status: _status,
      expectedWordCount: _wordCount,
    );
    await widget.repo.update(updated);
    widget.onTitleChanged(updated.title);
  }

  Future<void> _bindChapter() async {
    if (widget.currentChapterId == null) return;
    await widget.linkRepo.create(
      fromType: 'outline_node',
      fromId: widget.nodeId,
      toType: 'chapter',
      toId: widget.currentChapterId!,
      linkType: 'bound_to',
    );
    await _load();
  }

  Future<void> _unbindChapter() async {
    if (widget.currentChapterId == null) return;
    final links = await widget.linkRepo.findByFrom(
      fromType: 'outline_node',
      fromId: widget.nodeId,
    );
    for (final link in links) {
      if (link.toType == 'chapter' && link.toId == widget.currentChapterId) {
        await widget.linkRepo.deleteById(link.id);
      }
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_node == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '节点标题',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDropdown('类型', _type,
                    ['main_arc', 'sub_arc', 'scene', 'free'], (v) {
                  setState(() => _type = v);
                  _scheduleSave();
                }),
                const SizedBox(width: 16),
                _buildDropdown('状态', _status,
                    ['planning', 'writing', 'done'], (v) {
                  setState(() => _status = v);
                  _scheduleSave();
                }),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '预估字数',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    controller: _wordCountController,
                    onChanged: (v) {
                      setState(() => _wordCount = int.tryParse(v) ?? 0);
                      _scheduleSave();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.currentChapterId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    if (_isBound)
                      ElevatedButton.icon(
                        onPressed: _unbindChapter,
                        icon: const Icon(Icons.link_off, size: 16),
                        label: const Text('解绑当前章节'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _bindChapter,
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('绑定当前章节'),
                      ),
                    const SizedBox(width: 12),
                    if (_boundChapterIds != null &&
                        _boundChapterIds!.isNotEmpty)
                      Text('已绑定 ${_boundChapterIds!.length} 个章节',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ),
            TextField(
              controller: _descController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '节点描述',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _scheduleSave(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        key: ValueKey(label),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(_typeLabel(o))))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'main_arc':
        return '主线';
      case 'sub_arc':
        return '支线';
      case 'scene':
        return '场景';
      case 'free':
        return '自由';
      case 'planning':
        return '规划中';
      case 'writing':
        return '写作中';
      case 'done':
        return '已完成';
      default:
        return type;
    }
  }
}
