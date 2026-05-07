import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/module/knowledge_module.dart';
import '../../core/module/module_context.dart';
import '../../core/repositories/entity_link_repository.dart';
import '../../providers/app_providers.dart';
import 'character_repository.dart';
import 'character_model.dart';

class CharacterModule extends KnowledgeModule {
  static const entityTypeValue = 'character';
  late ModuleContext _context;
  late CharacterRepository _repo;
  final _uuid = const Uuid();
  final ValueNotifier<String?> selectedId = ValueNotifier(null);

  @override
  String get moduleId => 'character';

  @override
  String get displayName => '角色';

  @override
  String get entityType => entityTypeValue;

  @override
  Future<void> initialize(ModuleContext context) async {
    _context = context;
    _repo = CharacterRepository(context.database);
  }

  @override
  void dispose() {
    selectedId.dispose();
    super.dispose();
  }

  @override
  Future<Map<String, dynamic>> getContextForChapter(String chapterId) async {
    final logs = await _repo.getLogsByChapter(chapterId);
    final charIds = logs.map((l) => l.characterId).toSet();
    final charMap = await _repo.getByIds(charIds);
    final characters = <Map<String, dynamic>>[];
    for (final log in logs) {
      final ch = charMap[log.characterId];
      if (ch == null) continue;
      characters.add({
        'id': ch.id,
        'name': ch.name,
        'currentStatus': ch.currentStatus,
        'personalityTags': ch.personalityTagsList,
        'isDead': ch.isDead,
        'summary': log.summary,
      });
    }
    return {'module': moduleId, 'characters': characters};
  }

  @override
  Future<void> onChapterSaved(String chapterId, String content) async {}

  @override
  Future<void> onChapterCompleted(String chapterId, String content) async {}

  @override
  Widget? buildNavigationPanel(BuildContext context) {
    return _CharacterList(
      repo: _repo,
      module: this,
      selectedNotifier: selectedId,
    );
  }

  @override
  Widget? buildEditor(BuildContext context) {
    return _CharacterEditorHost(
      module: this,
      repo: _repo,
      selectedNotifier: selectedId,
      linkRepo: _context.linkRepo,
    );
  }

  @override
  Widget? buildInspector(BuildContext context, String entityId) {
    return null;
  }

  @override
  Future<void> handleLink(
      String fromEntityId, String toEntityId, String linkType) async {
    if (linkType != 'bound_to') return;
    await _context.linkRepo.create(
      fromType: entityTypeValue,
      fromId: fromEntityId,
      toType: 'chapter',
      toId: toEntityId,
      linkType: linkType,
    );
  }

  @override
  Future<List<SearchResult>> search(String query) async {
    final results = await _repo.search(query);
    return results.map((c) => SearchResult(
      moduleId: moduleId,
      entityId: c.id,
      title: c.name,
      snippet: c.currentStatus,
      entityType: entityTypeValue,
    )).toList();
  }

  Future<void> createCharacter(String name, {String? bookId}) async {
    final now = DateTime.now();
    await _repo.create(CharactersCompanion.insert(
      id: _uuid.v4(),
      name: name,
      bookId: Value(bookId),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<void> renameCharacter(String id, String newName) async {
    final ch = await _repo.getById(id);
    if (ch != null) await _repo.update(ch.copyWith(name: newName));
  }

  Future<void> deleteCharacter(String id) async {
    await _repo.delete(id);
  }
}

// ==================== 角色列表 ====================

class _CharacterList extends ConsumerStatefulWidget {
  final CharacterRepository repo;
  final CharacterModule module;
  final ValueNotifier<String?> selectedNotifier;

  const _CharacterList({
    required this.repo,
    required this.module,
    required this.selectedNotifier,
  });

  @override
  ConsumerState<_CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends ConsumerState<_CharacterList> {
  List<Character> _characters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookId = ref.read(currentBookIdProvider);
    if (bookId == null) {
      if (!mounted) return;
      setState(() {
        _characters = [];
        _loading = false;
      });
      return;
    }
    final list = await widget.repo.getAll(bookId: bookId);
    if (!mounted) return;
    setState(() {
      _characters = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听当前书籍变化，自动刷新角色列表
    ref.listen<String?>(currentBookIdProvider, (prev, next) {
      if (prev != next) {
        _load();
      }
    });
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              const Text('角色列表', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                tooltip: '新建角色',
                onPressed: () => _showCreateDialog(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ),
        Expanded(
          child: _characters.isEmpty
              ? Center(
                  child: Text('暂无角色',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13)))
              : ValueListenableBuilder<String?>(
                  valueListenable: widget.selectedNotifier,
                  builder: (context, selectedId, _) {
                    return ListView(
                      children: _characters.map((ch) {
                        final isSelected = selectedId == ch.id;
                        return InkWell(
                          onTap: () => widget.selectedNotifier.value = ch.id,
                          onSecondaryTapDown: (details) => _showContextMenu(ch, details),
                          child: Container(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer.withAlpha(100)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Icon(ch.isDead ? Icons.heart_broken : Icons.person,
                                    size: 16, color: ch.isDead ? Colors.red : null),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(ch.name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w600 : null),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
      ],
    );
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建角色'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '角色名称'),
          onSubmitted: (_) => _doCreate(ctx, controller),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => _doCreate(ctx, controller),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _doCreate(BuildContext dialogCtx, TextEditingController controller) async {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    await widget.module.createCharacter(name,
        bookId: ref.read(currentBookIdProvider));
    await _load();
    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
  }

  void _showContextMenu(Character ch, TapDownDetails details) {
    final pos = details.globalPosition;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy),
      items: [
        PopupMenuItem(
          child: const Text('重命名'),
          onTap: () {
            final controller = TextEditingController(text: ch.name);
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('重命名角色'),
                content: TextField(controller: controller, autofocus: true),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                  FilledButton(
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        await widget.module.renameCharacter(ch.id, controller.text.trim());
                        await _load();
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          },
        ),
        PopupMenuItem(
          child: const Text('删除', style: TextStyle(color: Colors.red)),
          onTap: () => _showDeleteConfirm(ch),
        ),
      ],
    );
  }

  void _showDeleteConfirm(Character ch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除角色「${ch.name}」吗？\n此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.module.deleteCharacter(ch.id);
              if (widget.selectedNotifier.value == ch.id) {
                widget.selectedNotifier.value = null;
              }
              await _load();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ==================== 角色编辑器 ====================

class _CharacterEditorHost extends StatefulWidget {
  final CharacterModule module;
  final CharacterRepository repo;
  final ValueNotifier<String?> selectedNotifier;
  final EntityLinkRepository linkRepo;

  const _CharacterEditorHost({
    required this.module,
    required this.repo,
    required this.selectedNotifier,
    required this.linkRepo,
  });

  @override
  State<_CharacterEditorHost> createState() => _CharacterEditorHostState();
}

class _CharacterEditorHostState extends State<_CharacterEditorHost> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.selectedNotifier,
      builder: (context, characterId, _) {
        if (characterId == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 48,
                    color: Theme.of(context).colorScheme.outline.withAlpha(80)),
                const SizedBox(height: 12),
                Text('选择角色查看详情',
                    style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 14)),
              ],
            ),
          );
        }
        return _CharacterEditor(
          characterId: characterId,
          repo: widget.repo,
          linkRepo: widget.linkRepo,
        );
      },
    );
  }
}

class _CharacterEditor extends StatefulWidget {
  final String characterId;
  final CharacterRepository repo;
  final EntityLinkRepository linkRepo;

  const _CharacterEditor({
    required this.characterId,
    required this.repo,
    required this.linkRepo,
  });

  @override
  State<_CharacterEditor> createState() => _CharacterEditorState();
}

class _CharacterEditorState extends State<_CharacterEditor> {
  Character? _character;
  final _nameCtrl = TextEditingController();
  final _aliasesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _appearanceCtrl = TextEditingController();
  final _backgroundCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  bool _isDead = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _CharacterEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterId != widget.characterId) _load();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _nameCtrl.dispose();
    _aliasesCtrl.dispose();
    _tagsCtrl.dispose();
    _appearanceCtrl.dispose();
    _backgroundCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ch = await widget.repo.getById(widget.characterId);
    if (ch == null || !mounted) return;
    setState(() {
      _character = ch;
      _nameCtrl.text = ch.name;
      _aliasesCtrl.text = ch.aliases;
      _tagsCtrl.text = ch.personalityTagsList.join(',');
      _appearanceCtrl.text = ch.appearance;
      _backgroundCtrl.text = ch.background;
      _statusCtrl.text = ch.currentStatus;
      _isDead = ch.isDead;
    });
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    if (!mounted) return;
    if (_character == null) return;
    final updated = _character!.copyWith(
      name: _nameCtrl.text,
      aliases: _aliasesCtrl.text,
      personalityTagsList: _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      appearance: _appearanceCtrl.text,
      background: _backgroundCtrl.text,
      currentStatus: _statusCtrl.text,
      isDead: _isDead,
    );
    await widget.repo.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: '姓名', border: OutlineInputBorder()),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aliasesCtrl,
              decoration: const InputDecoration(hintText: '别名（逗号分隔）', border: OutlineInputBorder()),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(hintText: '性格标签（逗号分隔）', border: OutlineInputBorder()),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appearanceCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '外貌描述', border: OutlineInputBorder(), alignLabelWithHint: true),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _backgroundCtrl,
              maxLines: 5,
              decoration: const InputDecoration(hintText: '背景故事', border: OutlineInputBorder(), alignLabelWithHint: true),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statusCtrl,
              decoration: const InputDecoration(hintText: '当前状态', border: OutlineInputBorder()),
              onChanged: (_) => _scheduleSave(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('已死亡'),
              value: _isDead,
              onChanged: (v) => setState(() { _isDead = v; _scheduleSave(); }),
            ),
          ],
        ),
      ),
    );
  }
}
