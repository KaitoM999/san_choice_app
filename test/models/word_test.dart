import 'package:flutter_test/flutter_test.dart';
// プロジェクト名に合わせてパスを調整してください
import 'package:san_choice_app/models/word_model.dart'; 

void main() {
  group('Word Model Test', () {
    test('JSONからWordオブジェクトが正しく生成されること', () {
      // 1. テスト用の擬似データ（JSON形式）を用意
      final json = {
        "text": "hallo",
        "meaning": "こんにちは",
        "partOfSpeech": "挨拶",
        "example": "Hallo, wie geht es dir?",
        "exampleMeaning": "こんにちは、元気ですか？"
      };

      // 2. Word.fromJsonを実行
      final word = Word.fromJson(json);

      // 3. 各値が期待通りかチェック
      expect(word.text, 'hallo');
      expect(word.meaning, 'こんにちは');
      expect(word.partOfSpeech, '挨拶');
      expect(word.example, 'Hallo, wie geht es dir?');
      expect(word.exampleMeaning, 'こんにちは、元気ですか？');
    });

    test('JSONの値が欠けている場合に空文字で補完されること', () {
      // 一部のデータが欠けているケース
      final json = {
        "text": "Danke",
        "meaning": "ありがとう",
        // partOfSpeech などが欠落
      };

      final word = Word.fromJson(json);

      expect(word.text, 'Danke');
      expect(word.partOfSpeech, ''); // factoryで設定した ?? '' の挙動を確認
    });
  });
}