import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/view_models/auth_session_cubit.dart';

class SessionRouterRefresh extends ChangeNotifier {
  SessionRouterRefresh(AuthSessionCubit session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<Object?> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
