# 3択ロース (San Choice App) 🎅🎄

ベトナム語と言葉の壁を、楽しく、3択クイズで乗り越える学習アプリ。
1,200個の単語を200個のブロックに分け、サンタの「ニョッキ」とトナカイ「カルビ」と一緒に攻略します。

## 📖 設計ドキュメント (Documentation)

プロジェクトの根幹となる設計資料です。各ファイルをクリックして詳細を確認してください。

* **[コンセプト・要件定義](docs/concept.md)**
    * アプリの目的、ターゲット、主要機能の概要。
* **[画面遷移図 (UI Flow)](docs/ui_flow.md)**
    * Mermaid記法による画面の流れと、中止ボタン等の挙動。
* **[画面設計 (UI Design)](docs/ui_design.md)**
    * 各画面のレイアウト、共通デザイン、パーツ構成の詳細。
* **[クイズロジック仕様](docs/quiz_logic.md)**
    * 3択の生成アルゴリズム、シャッフル、学習セッションの流れ。
* **[データ構造設計](docs/data_structure.md)**
    * 1,200単語のJSON形式、進捗データの保存方法。
* **[キャラクター仕様](docs/characters.md)**
    * サンタ「ニョッキ」とトナカイ「カルビ」のアクションと表情。

## 🛠 技術スタック (Tech Stack)

* **Framework:** Flutter (Dart)
* **Storage:** JSON (Master Data) / Shared Preferences (User Progress)
* **Diagrams:** Mermaid.js

## 🚀 開発の進め方

1.  `docs/` 内の各ドキュメントで仕様を把握する。
2.  `assets/data/` に単語データを配置する。
3.  `lib/` 内で各画面の実装を進める。