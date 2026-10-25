import 'dart:async';
import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/presentation/paged_read_cubit.dart';
import 'package:centrally/core/widgets/paged_read_body.dart';
import 'package:centrally/core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets(
      'skeleton reduced motion, accessible geometry and loaded transition $locale',
      (tester) async {
        final gate = Completer<ReadPage<int, int>>();
        final cubit = PagedReadCubit<int, int>(
          (_, c) => gate.future,
          (r) => '$r',
        );
        final work = cubit.refresh();
        addTearDown(cubit.close);
        final key = await pumpSessionDesign(
          tester,
          () => Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(2),
              ),
              child: BlocProvider.value(
                value: cubit,
                child: PagedReadBody<int, int>(item: (_, r) => Text('real-$r')),
              ),
            ),
          ),
          locale: locale,
          width: 320,
        );
        expect(find.byType(ContentSkeleton), findsOneWidget);
        expect(find.text('real-1'), findsNothing);
        final semantics = tester.ensureSemantics();
        expect(find.bySemanticsLabel('loading_data'.tr()), findsWidgets);
        await tester.runAsync(
          () => captureWidget(key, 'build/performance/skeleton-$locale.png'),
        );
        gate.complete(
          ReadPage(
            rows: [1],
            summary: 0,
            total: 1,
            syncedAt: DateTime.utc(2026),
          ),
        );
        await work;
        await tester.pumpAndSettle();
        expect(find.byType(ContentSkeleton), findsNothing);
        expect(find.text('real-1'), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}
