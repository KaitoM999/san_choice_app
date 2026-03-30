# データ構造設計 (Data Structure)

このドキュメントでは、アプリで使用する単語データ、進捗記録、およびキャラクターの状態管理に関する構造を定義します。

## 1. 単語マスターデータ (JSON)
全1,200単語は、1ブロック6問単位で管理します。
`assets/data/words_master.json` として保存する想定です。

### データ構造イメージ
```json
{
  "blocks": [
    {
      "block_id": 1,
      "words": [
        {
          "word_id": "w0001",
          "ja": "こんにちは",
          "vi": "Xin chào",
          "pos": "感動詞",
          "audio_path": "audio/w0001_vi.mp3",
          "example_ja": "皆さん、こんにちは。",
          "example_vi": "Chào mọi người.",
          "example_audio_path": "audio/ex0001_vi.mp3"
        },
        // ... 残り5単語
      ]
    },
    // ... 合計200ブロック
  ]
}