import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/color_manager.dart';
import '../../../screens/teacher/widgets/workspace_action_button.dart';
import 'teacher_notifications_page.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  Timer? _timer;
  int? _count;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resume();
  }

  void _resume() {
    _timer?.cancel();
    unawaited(_refresh());
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refresh()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resume();
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final data = await getIt<TeacherReadClient>().read(
        TeacherRead.notifications,
        params: {'p_limit': 1},
        refresh: true,
      );
      final count = readCount(readMap(data)['unread_count']);
      if (mounted) setState(() => _count = count);
    } catch (_) {
      if (mounted) setState(() => _count = null);
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WorkspaceActionButton(
    boxed: true,
    tooltip: 'completion_notifications'.tr(),
    icon: Badge(
      isLabelVisible: (_count ?? 0) > 0,
      backgroundColor: ColorManager.error,
      textColor: ColorManager.white,
      label: Semantics(
        label: 'completion_unread'.tr(args: ['${_count ?? 0}']),
        excludeSemantics: true,
        child: Text((_count ?? 0) > 99 ? '99+' : '${_count ?? 0}'),
      ),
      child: SvgPicture.asset('assets/icons/home_notification.svg'),
    ),
    onPressed: () async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const TeacherNotificationsPage(),
        ),
      );
      if (mounted) await _refresh();
    },
  );
}
