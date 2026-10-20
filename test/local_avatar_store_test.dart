import 'dart:io';
import 'dart:typed_data';
import 'package:centrally/core/data/local_avatar_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'avatar persists across store instances and remains account scoped',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'centerly-avatar-test-',
      );
      try {
        final bytes = await File(
          'assets/images/logo_app_icon.png',
        ).readAsBytes();
        final store = LocalAvatarStore(
          'preview-teacher-a',
          directory: directory,
        );
        await store.save(bytes);
        expect(
          await LocalAvatarStore(
            'preview-teacher-a',
            directory: directory,
          ).read(),
          bytes,
        );
        expect(
          await LocalAvatarStore(
            'preview-teacher-b',
            directory: directory,
          ).read(),
          isNull,
        );
        await expectLater(store.save(Uint8List(0)), throwsFormatException);
        await expectLater(
          store.save(Uint8List(LocalAvatarStore.maxBytes + 1)),
          throwsFormatException,
        );
        await expectLater(
          store.save(Uint8List.fromList([1, 2, 3])),
          throwsA(anything),
        );
        expect(
          await store.read(),
          bytes,
        ); // Rejected picks preserve previous image.
        await store.remove();
        expect(await store.read(), isNull);
        await store.remove();
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
