class LanguageConfig {
  final String id;
  final String name;
  final String ttsCode;
  final String jsonFileName;
  final String flag; // 💡 これを追加！

  LanguageConfig({
    required this.id,
    required this.name,
    required this.ttsCode,
    required this.jsonFileName,
    required this.flag,
  });

  static final List<LanguageConfig> supportedLanguages = [
    LanguageConfig(id: 'vi', name: 'ベトナム語 (Tiếng Việt)', ttsCode: 'vi-VN', jsonFileName: 'word_data_vi.json', flag: '🇻🇳'),
    LanguageConfig(id: 'zh', name: '中国語 (中文)', ttsCode: 'zh-CN', jsonFileName: 'word_data_zh.json', flag: '🇨🇳'),
    LanguageConfig(id: 'ko', name: '韓国語 (한국어)', ttsCode: 'ko-KR', jsonFileName: 'word_data_ko.json', flag: '🇰🇷'),
    LanguageConfig(id: 'ru', name: 'ロシア語 (Русский)', ttsCode: 'ru-RU', jsonFileName: 'word_data_ru.json', flag: '🇷🇺'),
    LanguageConfig(id: 'fr', name: 'フランス語 (Français)', ttsCode: 'fr-FR', jsonFileName: 'word_data_fr.json', flag: '🇫🇷'),
    LanguageConfig(id: 'de', name: 'ドイツ語 (Deutsch)', ttsCode: 'de-DE', jsonFileName: 'word_data_de.json', flag: '🇩🇪'),
    LanguageConfig(id: 'es', name: 'スペイン語 (Español)', ttsCode: 'es-ES', jsonFileName: 'word_data_es.json', flag: '🇪🇸'),
  ];
}