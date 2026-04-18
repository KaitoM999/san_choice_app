import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:san_choice_app/widgets/global_banner_ad.dart';

void main() {
  // 💡 外部プラグイン（AdMob）の初期化をモック化するために必要
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 実際のアプリでは main で MobileAds.instance.initialize() を呼びますが、
    // テストでは無視するか、モックが必要な場合があります。
  });

  group('GlobalBannerAd Widget Test', () {
    testWidgets('初期状態では広告が表示されず SizedBox.shrink (サイズ0) であること', (WidgetTester tester) async {
      // ウィジェットの描画
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlobalBannerAd(),
          ),
        ),
      );

      // _isAdLoaded は初期値 false なので、SizedBox.shrink を探す
      // 直接 SizedBox.shrink を特定するのは難しいため、Container (広告表示用) が存在しないことを確認
      expect(find.byType(Container), findsNothing);
      expect(find.byType(AdWidget), findsNothing);
    });

    testWidgets('ウィジェットがエラーなく作成されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalBannerAd(),
          ),
        ),
      );

      // 指定したTypeのウィジェットが1つ存在することを確認
      expect(find.byType(GlobalBannerAd), findsOneWidget);
    });
  });
}