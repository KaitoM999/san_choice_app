import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:san_choice_app/screens/character_intro_screen.dart';

void main() {
  group('CharacterIntroScreen Widget Test', () {
    
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      // 画面サイズを標準的なスマホサイズに設定
      binding.platformDispatcher.implicitView!.physicalSize = const Size(400, 800);
      binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;
    });

    testWidgets('キャラクター紹介画面の全要素テスト', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CharacterIntroScreen()));

      // 1. ヘッダー確認
      expect(find.text('キャラクター紹介'), findsOneWidget);

      // 2. スクロールして各キャラを確認
      // 💡 コード内に実在するテキストのみをリスト化
      final List<String> targets = [
        'ロースちゃん',
        'トナカイくん',
        'ターキー博士',
        'クロスさん',
        'ロースちゃんのお母さん' // クロスさんの詳細テキスト
      ];

      for (var text in targets) {
        bool found = false;
        for (int i = 0; i < 15; i++) {
          if (find.text(text).evaluate().isNotEmpty) {
            found = true;
            break;
          }
          // ListView を見つけてスクロール
          await tester.drag(find.byType(ListView), const Offset(0, -400));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(found, true, reason: "$text が見つかりませんでした");
        print('✅ $text を確認');
      }
    });

    testWidgets('戻るボタンのテスト', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CharacterIntroScreen()),
            ),
            child: const Text('Go'),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // 戻るボタン（Icons.arrow_back_ios）をタップ
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.text('Go'), findsOneWidget);
    });
  });
}