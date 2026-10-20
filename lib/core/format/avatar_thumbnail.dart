import 'dart:typed_data';
import 'dart:ui' as ui;

/// Validate metadata before decoding; persist a bounded, metadata-free thumbnail.
Future<Uint8List> avatarThumbnail(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final width = descriptor.width, height = descriptor.height;
      if (width <= 0 || height <= 0 || width * height > 24000000) {
        throw const FormatException('Oversized avatar dimensions');
      }
      final longest = width > height ? width : height;
      final w = longest > 512 ? (width * 512 ~/ longest).clamp(1, 512) : width;
      final h = longest > 512
          ? (height * 512 ~/ longest).clamp(1, 512)
          : height;
      final codec = await descriptor.instantiateCodec(
        targetWidth: w,
        targetHeight: h,
      );
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null) throw const FormatException('Avatar encode failed');
          return data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
    }
  } finally {
    buffer.dispose();
  }
}
