import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  MenuItem(this.label, this.icon, this.onTap);
}
