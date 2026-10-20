import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';

class TeacherAvatarImage extends StatelessWidget {
  const TeacherAvatarImage({this.bytes, super.key});
  final Uint8List? bytes;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: AppSize.s24,
    backgroundColor: ColorManager.primaryBright,
    foregroundColor: ColorManager.primaryDark,
    child: bytes == null
        ? const Icon(Icons.person_rounded, size: AppSize.s32)
        : ClipOval(
            child: Image(
              image: ResizeImage(
                MemoryImage(bytes!),
                width: 144,
                height: 144,
                policy: ResizeImagePolicy.fit,
              ),
              width: AppSize.s48,
              height: AppSize.s48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.person_rounded),
            ),
          ),
  );
}
