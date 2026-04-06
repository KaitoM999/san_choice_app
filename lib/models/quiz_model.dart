class WordDetail {
  final String text;
  final String meaning;
  final String partOfSpeech;
  final String example;
  final String exampleMeaning;

  WordDetail({
    required this.text,
    required this.meaning,
    required this.partOfSpeech,
    required this.example,
    required this.exampleMeaning,
  });

  // JSON(Map) から WordDetail オブジェクトを作る工場
  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      text: json['text'] ?? '',
      meaning: json['meaning'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      example: json['example'] ?? '',
      exampleMeaning: json['exampleMeaning'] ?? '',
    );
  }
}

class Quiz {
  final WordDetail question;
  final List<WordDetail> options;
  final int correctIndex;

  Quiz({
    required this.question,
    required this.options,
    required this.correctIndex,
  }); // ← ここにセミコロンが必要でした！

  // JSON(Map) から Quiz オブジェクトを作る工場
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      // 子要素も .fromJson を呼んで変換するのがポイント
      question: WordDetail.fromJson(json['question']),
      options: (json['options'] as List)
          .map((item) => WordDetail.fromJson(item))
          .toList(),
      correctIndex: json['correctIndex'],
    );
  }
}