import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: EditorPage()),
        ],
      ),
    );
  }
}
