import 'package:bloc/bloc.dart';
import '../diagnostics/app_diagnostics.dart';

class MyBlocObserver extends BlocObserver {
  const MyBlocObserver();
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppDiagnostics.current.failure(
      'bloc.error',
      'UNHANDLED_ERROR',
      stackTrace,
      error,
    );
    super.onError(bloc, error, stackTrace);
  }
}
