import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/preview_mode.dart';
import '../../../core/data/local_avatar_store.dart';
import '../../../core/di/di.dart';
import 'teacher_avatar_image.dart';
import 'teacher_avatar_menu.dart';
import '../../../features/auth/presentation/view_models/auth_session_cubit.dart';

class TeacherAvatar extends StatefulWidget {
  const TeacherAvatar({super.key});
  @override
  State<TeacherAvatar> createState() => _TeacherAvatarState();
}

class _TeacherAvatarState extends State<TeacherAvatar> {
  final _picker = ImagePicker();
  late final LocalAvatarStore _store;
  Uint8List? _bytes;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    final id = getIt.isRegistered<AuthSessionCubit>()
        ? getIt<AuthSessionCubit>().state.profile?.id
        : null;
    final url = getIt.isRegistered<AppConfig>() ? getIt<AppConfig>().url : '';
    _store = LocalAvatarStore('${PreviewMode.enabled ? 'preview' : url}_$id');
    _restore();
  }

  Future<void> _restore() async {
    try {
      final bytes = await _store.read();
      if (mounted) setState(() => _bytes = bytes);
      if (Platform.isAndroid) {
        final lost = await _picker.retrieveLostData();
        if (lost.files?.isNotEmpty == true) await _save(lost.files!.first);
      }
    } catch (_) {
      /* Keep the fallback avatar usable. */
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(XFile file) async {
    if (await file.length() > LocalAvatarStore.maxBytes) {
      throw const FormatException();
    }
    final bytes = await file.readAsBytes();
    await _store.save(bytes);
    if (mounted) setState(() => _bytes = bytes);
  }

  Future<void> _change(bool remove) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (remove) {
        await _store.remove();
        if (mounted) setState(() => _bytes = null);
      } else {
        final file = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
          requestFullMetadata: false,
        );
        if (file != null) await _save(file);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('teacher_photo_failed'.tr())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => TeacherAvatarMenu(
    enabled: !_busy,
    hasPhoto: _bytes != null,
    onChange: _change,
    child: TeacherAvatarImage(bytes: _bytes),
  );
}
