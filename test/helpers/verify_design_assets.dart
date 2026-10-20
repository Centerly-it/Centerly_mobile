import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Check exported SVG geometry at the actual callsites, not just asset presence.
void verifyDesignAssets(WidgetTester tester, String manifestPath) {
  final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as Map;
  final sizes = {
    for (final asset in manifest['assets'] as List)
      if (asset['width'] != null)
        asset['path']: Size(
          (asset['width'] as num).toDouble(),
          (asset['height'] as num).toDouble(),
        ),
  };
  for (final svg in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
    if (svg.bytesLoader case SvgAssetLoader(:final assetName)) {
      if (sizes[assetName] case final Size size) {
        expect(tester.getSize(find.byWidget(svg)), size, reason: assetName);
        expect(File(assetName).lengthSync(), greaterThan(0));
      }
    }
  }
  final imageSizes = {
    for (final asset in manifest['assets'] as List)
      if (asset['renderSizes'] != null)
        asset['path']: asset['renderSizes'] as List,
  };
  for (final image in tester.widgetList<Image>(find.byType(Image))) {
    if (image.image case AssetImage(:final assetName)) {
      final allowed = imageSizes[assetName];
      if (allowed != null) {
        final actual = tester.getSize(find.byWidget(image));
        expect(
          allowed.any(
            (size) =>
                (actual.width - size[0]).abs() < 0.001 &&
                (actual.height - size[1]).abs() < 0.001,
          ),
          isTrue,
          reason: assetName,
        );
        expect(File(assetName).lengthSync(), greaterThan(0));
      }
    }
  }
}
