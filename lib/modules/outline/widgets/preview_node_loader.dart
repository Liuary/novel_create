import 'package:flutter/material.dart';
import '../outline_node_model.dart';
import '../outline_repository.dart';
import 'outline_visual_preview.dart';

class PreviewNodeLoader extends StatefulWidget {
  final OutlineRepository repo;
  final String nodeId;
  final String? bookId;

  const PreviewNodeLoader({
    super.key,
    required this.repo,
    required this.nodeId,
    this.bookId,
  });

  @override
  State<PreviewNodeLoader> createState() => PreviewNodeLoaderState();
}

class PreviewNodeLoaderState extends State<PreviewNodeLoader> {
  Future<OutlineNode?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PreviewNodeLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodeId != widget.nodeId) _load();
  }

  void _load() {
    _future = widget.repo.getById(widget.nodeId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OutlineNode?>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return OutlineVisualPreview(
          key: ValueKey(widget.nodeId),
          repo: widget.repo,
          bookId: widget.bookId,
          rootNode: snapshot.data!,
        );
      },
    );
  }
}
