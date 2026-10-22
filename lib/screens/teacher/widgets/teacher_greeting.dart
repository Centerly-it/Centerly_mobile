import '../../../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../../../core/di/di.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/config/preview_mode.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';

class TeacherGreeting extends StatefulWidget {
  const TeacherGreeting({this.now, super.key});
  final DateTime? now;
  @override
  State<TeacherGreeting> createState() => _TeacherGreetingState();
}

class _TeacherGreetingState extends State<TeacherGreeting> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && widget.now == null) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = CairoTime.local(widget.now ?? DateTime.now());
    final displayName = getIt.isRegistered<AuthSessionCubit>()
        ? getIt<AuthSessionCubit>().state.profile?.displayName
        : null;
    final name =
        displayName ??
        (PreviewMode.enabled
                ? 'home_preview_teacher_name'
                : 'home_teacher_name_fallback')
            .tr();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (now.hour < 12 ? 'home_greeting_morning' : 'home_greeting_evening')
              .tr(args: [name]),
          maxLines: MediaQuery.textScalerOf(context).scale(16) > 21 ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleMedium.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSize.s4),
        Text(
          DateFormat.yMMMMEEEEd(context.locale.toString()).format(now),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(color: ColorManager.white),
        ),
      ],
    );
  }
}
