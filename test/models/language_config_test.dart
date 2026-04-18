import 'package:flutter_test/flutter_test.dart';
// プロジェクト名に合わせてパスを調整してください
import 'package:san_choice_app/models/language_config.dart';

void main() {
  group('LanguageConfig Test', () {
    test('サポートされている言語リストが空ではないこと', () {
      final languages = LanguageConfig.supportedLanguages;
      
      expect(languages.isNotEmpty, true);
      expect(languages.length, 7); // 現在の定義数と一致するか
    });

    test('ドイツ語(de)の設定が正しく定義されていること', () {
      // リストからidが'de'のものを探す
      final german = LanguageConfig.supportedLanguages
          .firstWhere((lang) => lang.id == 'de');

      expect(german.name, 'ドイツ語 (Deutsch)');
      expect(german.ttsCode, 'de-DE');
      expect(german.jsonFileName, 'word_data_de.json');
      expect(german.flag, '🇩🇪');
    });

    test('すべての言語で必要なフィールドが埋まっていること', () {
      for (var lang in LanguageConfig.supportedLanguages) {
        expect(lang.id.isNotEmpty, true, reason: '${lang.name} の id が空です');
        expect(lang.ttsCode.contains('-'), true, reason: '${lang.name} の ttsCode が不正です');
        expect(lang.jsonFileName.endsWith('.json'), true, reason: '${lang.name} のファイル名が不正です');
        expect(lang.flag.isNotEmpty, true, reason: '${lang.name} の国旗が設定されていません');
      }
    });
  });
}