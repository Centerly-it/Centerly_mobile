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
  testWidgets('dragging receipts scrolls filters and outer header together', (
    tester,
  ) async {
    final cubit = PagedReadCubit<int, int>(
      (_, cursor) async => ReadPage(
        rows: List.generate(30, (i) => i),
        summary: 0,
        total: 30,
        syncedAt: DateTime.utc(2026, 10, 25),
      ),
      (row) => '$row',
    );
    await cubit.refresh();
    addTearDown(cubit.close);
    await pumpSessionDesign(
      tester,
      () => Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: NestedScrollView(
            headerSliverBuilder: (_, inner) => [
              const SliverToBoxAdapter(
                child: SizedBox(height: 140, child: Text('month-tabs')),
              ),
            ],
            body: PagedReadBody<int, int>(
              leading: const SizedBox(height: 180, child: Text('filters')),
              item: (_, row) =>
                  SizedBox(height: 80, child: Text('receipt-$row')),
            ),
          ),
        ),
      ),
      height: 700,
    );
    expect(find.text('filters'), findsOneWidget);
    await tester.drag(find.text('receipt-1'), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('filters'), findsNothing);
    expect(
      tester
          .state<NestedScrollViewState>(find.byType(NestedScrollView))
          .innerController
          .offset,
      greaterThan(180),
    );
    expect(
      tester
          .state<NestedScrollViewState>(find.byType(NestedScrollView))
          .outerController
          .offset,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });
}
