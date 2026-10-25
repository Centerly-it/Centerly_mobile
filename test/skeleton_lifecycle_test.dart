import 'package:centrally/core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  testWidgets('inactive tab and app pause stop loading animation', (
    tester,
  ) async {
    bool visible = false;
    late StateSetter update;
    await pumpSessionDesign(
      tester,
      () => Scaffold(
        body: StatefulBuilder(
          builder: (context, set) {
            update = set;
            return TickerMode(
              enabled: visible,
              child: const ContentSkeleton(count: 1),
            );
          },
        ),
      ),
    );
    Skeletonizer skeleton() => tester.widget<Skeletonizer>(
      find.byWidgetPredicate((w) => w is Skeletonizer),
    );
    expect(skeleton().effect, isA<SolidColorEffect>());
    update(() => visible = true);
    await tester.pump();
    expect(skeleton().effect, isA<ShimmerEffect>());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(skeleton().effect, isA<SolidColorEffect>());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(skeleton().effect, isA<ShimmerEffect>());
    update(() => visible = false);
    await tester.pumpAndSettle();
    expect(skeleton().effect, isA<SolidColorEffect>());
    expect(tester.takeException(), isNull);
  });
}
