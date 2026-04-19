# データ構造設計 (Data Structure)

このドキュメントでは、アプリ「3択ロース」で使用する単語データ、言語設定、および進捗記録の保存構造を定義します。

## 1. 言語設定データ (Language Config)
アプリがサポートする各言語の設定は `lib/models/language_config.dart` で管理されます。

### プロパティ構成
- **id**: 言語識別子（例: 'vi', 'zh'）
- **name**: 表示名（例: 'ベトナム語 (Tiếng Việt)'）
- **ttsCode**: FlutterTtsで使用する言語コード（例: 'vi-VN'）
- **jsonFileName**: 読み込むJSONファイル名（例: 'word_data_vi.json'）
- **flag**: 表示用国旗絵文字

---

## 2. 単語マスターデータ (JSON)
各言語の単語データは `assets/data/word_data_{id}.json` にフラットなリスト形式で保存されます。
クイズ実行時に、アプリ側で6問ずつの「ブロック」として分割処理されます。

### データ構造 (例: `word_data_de.json`)
```json
[
  {
    "id": 1,
    "text": "Hallo",
    "meaning": "こんにちは",
    "partOfSpeech": "挨拶",
    "example": "Hallo, wie geht es dir?",
    "exampleMeaning": "こんにちは、元気ですか？"
  }
]