import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:san_choice_app/screens/quiz_screen.dart';
import 'package:san_choice_app/models/language_config.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // 💡 テスト開始前に Google Fonts の通信を完全にシャットアウト
  GoogleFonts.config.allowRuntimeFetching = false;

  TestWidgetsFlutterBinding.ensureInitialized();

  final mockLanguage = LanguageConfig.supportedLanguages.firstWhere((l) => l.id == 'de');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    
    // MethodChannelのモック（TTSと広告）
    const MethodChannel('flutter_tts').setMockMethodCallHandler((call) async => null);
    const MethodChannel('google_mobile_ads').setMockMethodCallHandler((call) async => null);

    // 💡 低レイヤーでのアセットフック
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      
      final String key = utf8.decode(message.buffer.asUint8List(), allowMalformed: true);

      // 1. クイズ用のJSONリクエストのみに応答
      if (key.startsWith('assets/data/') && key.endsWith('.json')) {
        final List<Map<String, String>> mockData = List.generate(10, (i) => {
          "text": "Word$i",
          "meaning": "意味$i",
          "partOfSpeech": "名詞",
          "example": "Example$i",
          "exampleMeaning": "例文意味$i"
        });
        final encoded = utf8.encoder.convert(json.encode(mockData));
        return ByteData.view(encoded.buffer);
      }
      
      // 💡 2. AssetManifest.bin のリクエストには「空のマップ」を標準的な形式で返す
      // これにより Google Fonts や Flutter 内部の読み込みが FormatException を起こさなくなります
      if (key == 'AssetManifest.bin' || key == 'AssetManifest.json') {
        // 標準的な MessageCodec 形式の空の目録
        final ByteData data = const StandardMessageCodec().encodeMessage(<String, List<Object>>{})!;
        return data;
      }

      // 3. それ以外はスルー（システムに任せる）
      return null; 
    });
  });

  testWidgets('QuizScreen の全機能テスト（表示・回答・次へ）', (WidgetTester tester) async {
    // 💡 実行中の非同期エラー（フォントロード等）をこのテスト内で完結させる
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          // 💡 フォント読み込みエラーの影響を最小限にするため空のテーマを指定
          theme: ThemeData(textTheme: const TextTheme()),
          home: QuizScreen(
            blockNumber: 1,
            isVietToJpn: true,
            currentLanguage: mockLanguage,
          ),
        ),
      );

      // ロード待ち（クイズが出るまで）
      bool loaded = false;
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byIcon(Icons.volume_up).evaluate().isNotEmpty) {
          loaded = true;
          break;
        }
      }
      
      if (!loaded) fail("クイズデータの読み込みが完了しませんでした。");

      // --- 検証1: 表示 ---
      expect(find.textContaining('Block 1'), findsOneWidget);

      // --- 検証2: 回答 ---
      final optionButtons = find.byType(ElevatedButton);
      await tester.tap(optionButtons.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('【 解説 】'), findsOneWidget);

      // --- 検証3: 次の問題へ ---
      await tester.tap(find.text('次の問題へ'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // [2/6] になっていることを確認
      expect(find.textContaining('[2/6]'), findsOneWidget);
    });
  });
}