import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<void> captureWidget(GlobalKey key, String path) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List());
  image.dispose();
}
