import 'package:flutter/services.dart';

Future<void> loadTestFonts() async {
  final cairo = FontLoader('Cairo');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    cairo.addFont(rootBundle.load('assets/fonts/Cairo-$weight.ttf'));
  }
  await cairo.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}
