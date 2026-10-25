import 'dart:convert';
import 'dart:io';
import 'package:centrally/core/data/read_page.dart';
import 'package:centrally/core/presentation/paged_read_cubit.dart';
import 'package:centrally/core/widgets/paged_read_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  testWidgets('1000 paged records only build viewport children', (
    tester,
  ) async {
    var built = 0;
    final cubit = PagedReadCubit<int, int>(
      (_, c) async => ReadPage(
        rows: List.generate(1000, (i) => i),
        summary: 0,
        total: 1000,
        syncedAt: DateTime.utc(2026),
      ),
      (r) => '$r',
    );
    await cubit.refresh();
    addTearDown(cubit.close);
    var eager = 0;
    await pumpSessionDesign(
      tester,
      () => Scaffold(
        body: ListView(
          children: [
            for (var i = 0; i < 1000; i++)
              (() {
                eager++;
                return SizedBox(height: 80, child: Text('row-$i'));
              })(),
          ],
        ),
      ),
    );
    expect(eager, 1000);
    await pumpSessionDesign(
      tester,
      () => Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: PagedReadBody<int, int>(
            item: (_, row) {
              built++;
              return SizedBox(height: 80, child: Text('row-$row'));
            },
          ),
        ),
      ),
    );
    final initial = built;
    expect(initial, lessThan(30));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(built, lessThan(60));
    final report = {
      'mode':
          'Flutter widget test; structural counts, not device frame timings',
      'records': 1000,
      'viewport': [390, 909],
      'beforeEagerItemConstructions': eager,
      'afterInitialItemConstructions': initial,
      'afterScrollItemConstructions': built,
    };
    await tester.runAsync(() async {
      final f = File('build/performance/viewport.json');
      await f.parent.create(recursive: true);
      await f.writeAsString(jsonEncode(report));
    });
  });
}
