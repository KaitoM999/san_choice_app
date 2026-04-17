import 'word_model.dart';

class Quiz {
  final Word question;       // 問題になる単語
  final List<Word> options;  // 選択肢（正解1つ ＋ ランダムなダミー2つ）
  final int correctIndex;    // 正解が選択肢の何番目にあるか（0, 1, 2）

  Quiz({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}