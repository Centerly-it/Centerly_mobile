import 'session_attendance_row.dart';
import '../../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/data_update_footer.dart';
import '../data/session_detail_repository.dart';
import 'session_detail_cubit.dart';
import 'session_detail_state.dart';
import 'session_detail_header.dart';
import 'session_attendance_list.dart';

part 'session_detail_body.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.sessionId, super.key});
  final String sessionId;
  static Future<void> open(BuildContext context, String id) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => SessionDetailPage(sessionId: id)),
      );
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SessionDetailCubit(
      SessionDetailRepository(getIt<TeacherReadClient>()),
      sessionId,
    )..load(),
    child: Scaffold(
      appBar: AppBar(
        title: Text('session_details_title'.tr()),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'detail_refresh'.tr(),
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<SessionDetailCubit>().refresh(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SessionDetailCubit, SessionDetailState>(
          builder: (context, state) =>
              _SessionDetailBody(state: state, sessionId: sessionId),
        ),
      ),
    ),
  );
}
