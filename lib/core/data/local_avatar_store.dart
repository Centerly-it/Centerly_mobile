import 'dart:io';
import 'dart:typed_data';
import '../format/avatar_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

/// Device-local avatar only. Backend/account namespaces never share files.
class LocalAvatarStore {
  const LocalAvatarStore(this.scope, {this.directory});
  final String scope;
  final Directory? directory;
  static const maxBytes = 2 * 1024 * 1024;

  Future<File> _file() async {
    final root = directory ?? await getApplicationSupportDirectory();
    final safe = scope.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final folder = Directory('${root.path}/teacher_avatars');
    await folder.create(recursive: true);
    return File('${folder.path}/$safe.image');
  }

  Future<Uint8List?> read() async {
    try {
      final file = await _file();
      if (!await file.exists() || await file.length() > maxBytes) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Future<void> remove() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }

  Future<void> save(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > maxBytes) throw const FormatException();
    final thumbnail = await avatarThumbnail(bytes);
    if (thumbnail.length > maxBytes) throw const FormatException();
    final file = await _file();
    final pending = File('${file.path}.pending');
    await pending.writeAsBytes(thumbnail, flush: true);
    await pending.rename(file.path);
  }
}
