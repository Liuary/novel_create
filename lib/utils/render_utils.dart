import 'package:flutter/rendering.dart';

RenderEditable? findRenderEditable(RenderObject root) {
  if (root is RenderEditable) return root;
  RenderEditable? found;
  root.visitChildren((child) {
    found ??= findRenderEditable(child);
  });
  return found;
}
