class Word {
  final String text;
  final String meaning;
  final String partOfSpeech;
  final String example;
  final String exampleMeaning;

  Word({
    required this.text,
    required this.meaning,
    required this.partOfSpeech,
    required this.example,
    required this.exampleMeaning,
  });

  // JSONからWordオブジェクトを作る工場
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] ?? '',
      meaning: json['meaning'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      example: json['example'] ?? '',
      exampleMeaning: json['exampleMeaning'] ?? '',
    );
  }
}