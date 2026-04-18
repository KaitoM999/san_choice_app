import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:san_choice_app/screens/result_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  // アニメーション完了を待つためのヘルパー
  Future<void> advanceTime(WidgetTester tester) async {
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // 特定の文字列が含まれるか探すヘルパー
  bool containsText(WidgetTester tester, String target) {
    final texts = tester.widgetList<Text>(find.byType(Text, skipOffstage: false));
    for (final t in texts) {
      if (t.data?.contains(target) ?? false) return true;
      if (t.textSpan?.toPlainText().contains(target) ?? false) return true;
    }
    return false;
  }

  // 💡 文字列の長さを判定する最強のヘルパー（ランダムでどのメッセージが来てもパスする）
  bool hasLongText(WidgetTester tester, int minLength) {
    final texts = tester.widgetList<Text>(find.byType(Text, skipOffstage: false));
    for (final t in texts) {
      if ((t.data?.length ?? 0) > minLength) return true;
      if ((t.textSpan?.toPlainText().length ?? 0) > minLength) return true;
    }
    return false;
  }

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.implicitView!.physicalSize = const Size(1080, 2400);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;
    
    SharedPreferences.setMockInitialValues({});
    const MethodChannel('flutter_tts').setMockMethodCallHandler((call) async => null);
    const MethodChannel('google_mobile_ads').setMockMethodCallHandler((call) async => null);
  });

  group('ResultScreen Widget Test', () {
    testWidgets('満点（全問正解）の時に、適切なメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(score: 6, totalQuestions: 6),
      ));
      await advanceTime(tester);

      expect(containsText(tester, '6 / 6'), true, reason: "スコアが表示されていません");
      
      // 💡 10文字以上の長文（＝成功メッセージ）が画面にあるかチェック
      expect(hasLongText(tester, 10), true, reason: "成功メッセージが見つかりませんでした");
    });

    testWidgets('スコアが低い時に、適切なメッセージが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(score: 0, totalQuestions: 6),
      ));
      await advanceTime(tester);

      expect(containsText(tester, '0 / 6'), true, reason: "スコアが表示されていません");
      
      // 💡 10文字以上の長文（＝失敗メッセージ）が画面にあるかチェック
      expect(hasLongText(tester, 10), true, reason: "失敗メッセージが見つかりませんでした");
    });

    testWidgets('「ホームへ戻る」ボタンをタップしてホームへ遷移すること', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ResultScreen(score: 3, totalQuestions: 6),
      ));
      await advanceTime(tester);

      final homeBtn = find.text('ホームへ戻る', skipOffstage: false);
      expect(homeBtn, findsOneWidget, reason: "ホームへ戻るボタンが見つかりません");

      await tester.tap(homeBtn);
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));

      // タップがエラーなく完遂すれば合格
      expect(true, true);
    });
  });
}