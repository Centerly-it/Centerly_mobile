import 'dart:convert';
import 'dart:io';

Future<Map> runtimeTeacherAccount() async {
  final path = Platform.environment['CENTERLY_TEST_ACCOUNT_FILE'];
  if (path == null) {
    throw StateError(
      'Set CENTERLY_TEST_ACCOUNT_FILE to the ignored account file',
    );
  }
  final saved = jsonDecode(await File(path).readAsString()) as Map;
  if (saved['projectRef'] != 'yfeubomyglmhuwizaqoj') {
    throw StateError('Only the approved development project may be tested');
  }
  return (saved['accounts'] as List).cast<Map>().firstWhere(
    (account) => account['name'] == 'teacher-a',
  );
}
