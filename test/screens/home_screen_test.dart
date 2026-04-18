import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:san_choice_app/screens/home_screen.dart';
import 'package:san_choice_app/screens/word_list_screen.dart';
import 'package:san_choice_app/models/language_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen の全機能テスト（表示・言語選択・遷移）', (WidgetTester tester) async {
    // 1. セットアップ
    SharedPreferences.setMockInitialValues({'selected_language': 'de'});

    // 2. 画面起動
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    
    // 3. ロード待ち
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // --- 検証1: タイトル表示 ---
    expect(find.text('ドイツ語クイズ'), findsOneWidget);
    print('✅ タイトル表示チェック完了');

    // --- 検証2: 言語選択ドロップダウン ---
    final dropdownFinder = find.byType(DropdownButton<LanguageConfig>);
    
    // 開く
    await tester.tap(dropdownFinder);
    await tester.pump(const Duration(milliseconds: 500));
    
    // 選択肢が出ているか確認
    expect(find.textContaining('🇻🇳'), findsWidgets);
    print('✅ ドロップダウンチェック完了');

    // 💡 重要：ドロップダウンを閉じる
    // 選択肢以外の場所（一番上のタイトルのあたりなど）をタップしてメニューを閉じる
    await tester.tapAt(const Offset(10, 10)); 
    await tester.pump(const Duration(milliseconds: 500)); // 閉じるアニメーション待ち

    // --- 検証3: 画面遷移 ---
    // ボタンを探す
    final listButton = find.text('単語一覧（復習）');
    expect(listButton, findsOneWidget);

    // タップ（warnIfMissedを付けると重なり警告を無視できますが、今回は閉じたので大丈夫なはずです）
    await tester.tap(listButton);
    
    // 遷移アニメーション分、時間を進める
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // WordListScreen に辿り着いたか確認
    expect(find.byType(WordListScreen), findsOneWidget);
    print('✅ 画面遷移チェック完了');
  });
}