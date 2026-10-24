import 'dart:async';
import 'package:flutter/material.dart';
import '../core/di/di.dart';
import '../features/auth/presentation/view_models/auth_session_cubit.dart';

class SessionLifecycle extends StatefulWidget {
  const SessionLifecycle({required this.child, super.key});
  final Widget child;
  @override
  State<SessionLifecycle> createState() => _SessionLifecycleState();
}

class _SessionLifecycleState extends State<SessionLifecycle>
    with WidgetsBindingObserver {
  Timer? _timer;
  void _check({bool background = false}) {
    final session = getIt<AuthSessionCubit>();
    if (session.state.isAuthenticated) {
      unawaited(session.restore(background: background));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _check(background: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(background: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
