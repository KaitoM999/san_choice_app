import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:san_choice_app/screens/word_list_screen.dart';

void main() {
  // 💡 テストのBindingを確実に初期化
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WordListScreen の全機能テスト（表示・展開・アイコン）', (WidgetTester tester) async {
    // 1. モックの設定（各テストの最初に行うのが最も安全）
    SharedPreferences.setMockInitialValues({'selected_language': 'de'});

    // 💡 TTSのモック（MethodChannelを直接黙らせる）
    const MethodChannel('flutter_tts').setMockMethodCallHandler((methodCall) async {
      return null;
    });

    // 💡 アセット読み込みのモック（いかなる要求にもHausデータを返す）
    // ignore: deprecated_member_use
    tester.binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (message) async {
      final Uint8List encoded = utf8.encoder.convert(json.encode([
        {
          "text": "Haus",
          "meaning": "家",
          "partOfSpeech": "名詞",
          "example": "Das Haus ist groß.",
          "exampleMeaning": "その家は大きいです。"
        }
      ]));
      return encoded.buffer.asByteData();
    });

    // 2. 画面の起動
    await tester.pumpWidget(const MaterialApp(home: WordListScreen()));

    // 3. データのロード待ち（ループで粘る）
    bool loaded = false;
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Haus').evaluate().isNotEmpty) {
        loaded = true;
        break;
      }
    }

    if (!loaded) fail("Haus が見つかりませんでした。ロード失敗です。");

    // --- 検証1: 表示チェック ---
    expect(find.text('Haus'), findsOneWidget);
    expect(find.text('家'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsWidgets);
    print('✅ 表示チェック完了');

    // --- 検証2: タップ展開チェック ---
    expect(find.text('例文:'), findsNothing);
    
    // タイルをタップ
    await tester.tap(find.text('Haus'));
    
    // アニメーションを待つ（小刻みにpump）
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('例文:'), findsOneWidget);
    expect(find.text('Das Haus ist groß.'), findsOneWidget);
    print('✅ 展開チェック完了');
    
    // ignore: deprecated_member_use
    tester.binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });
}