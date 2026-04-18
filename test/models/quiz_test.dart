import 'package:flutter_test/flutter_test.dart';
import 'package:san_choice_app/models/word_model.dart';
import 'package:san_choice_app/models/quiz_model.dart'; // クラス名に合わせて調整

void main() {
  group('Quiz Model Test', () {
    // テスト用のダミー単語データ
    final wordA = Word(text: 'Apfel', meaning: 'りんご', partOfSpeech: '名詞', example: '', exampleMeaning: '');
    final wordB = Word(text: 'Banane', meaning: 'バナナ', partOfSpeech: '名詞', example: '', exampleMeaning: '');
    final wordC = Word(text: 'Zitrone', meaning: 'レモン', partOfSpeech: '名詞', example: '', exampleMeaning: '');

    test('Quizオブジェクトが正しく構成されること', () {
      final options = [wordA, wordB, wordC];
      const correctIndex = 1; // 正解はBanane

      final quiz = Quiz(
        question: wordB,
        options: options,
        correctIndex: correctIndex,
      );

      // 基本的なプロパティチェック
      expect(quiz.question.text, 'Banane');
      expect(quiz.options.length, 3);
      expect(quiz.correctIndex, 1);
      
      // correctIndexが指し示す単語が、問題の単語と一致するか
      expect(quiz.options[quiz.correctIndex].text, quiz.question.text);
    });

    test('正解インデックスが選択肢の範囲内であることのバリデーション（論理チェック）', () {
      final options = [wordA, wordB, wordC];
      
      final quiz = Quiz(
        question: wordA,
        options: options,
        correctIndex: 0,
      );

      // indexが 0 <= index < options.length であることを確認
      expect(quiz.correctIndex, greaterThanOrEqualTo(0));
      expect(quiz.correctIndex, lessThan(quiz.options.length));
    });
  });
}