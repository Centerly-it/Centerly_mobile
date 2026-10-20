import 'package:flutter_test/flutter_test.dart';
import 'verify_design_assets.dart';

void verifyGroupAssets(WidgetTester tester) =>
    verifyDesignAssets(tester, 'docs/FIGMA_GROUP_ASSETS.json');
