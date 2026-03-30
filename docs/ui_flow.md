# 画面遷移図 (UI Flow)

```mermaid
graph TD
    %% 画面要素の定義
    Home[<b>ホーム画面</b><br/>アプリ起動時]
    
    %% ブロック選択画面を詳細に
    BlockSelect[<b>クイズブロック選択画面</b><br/>・1〜200のブロックリスト<br/>・各ブロックの前回の点数表示<br/>・点数全件リセットボタン<br/>・<b>出題方向切り替え</b><br/>（日→越 ⇄ 越→日）]

    %% クイズループ（6回）
    subgraph QuizLoop [クイズサイクル（6回繰り返し）]
        QuizMain[<b>クイズ画面</b><br/>3択から選択]
        AnswerDetail[<b>回答・解説表示</b><br/>訳・品詞・音声・例文]
        
        QuizMain -->|回答する| AnswerDetail
        AnswerDetail -->|次へ| QuizMain
    end

    %% 結果発表画面
    Result[<b>結果発表画面</b><br/>今回のスコア表示]

    %% メインの遷移
    Home <==> BlockSelect
    BlockSelect ==>|ブロックを選択して開始| QuizMain
    QuizLoop ==>|6問終了| Result
    Result ==>|確認ボタン| BlockSelect

    %% 中止アクション（点数カウントなしで戻る）
    QuizMain -.->|中止ボタン| BlockSelect
    AnswerDetail -.->|中止ボタン| BlockSelect

    %% スタイルの調整
    %% 読みやすさを考慮したカラーパレット
    style Home fill:#f9f,stroke:#333,stroke-width:2px,color:black
    style BlockSelect fill:#bbf,stroke:#333,stroke-width:2px,color:black
    style Result fill:#bfb,stroke:#333,stroke-width:2px,color:black
    style QuizLoop fill:#1a237e,stroke:#333,stroke-width:1px,color:#fff
    style QuizMain fill:#f5f5f5,stroke:#333,stroke-width:1px,color:black
    style AnswerDetail fill:#f5f5f5,stroke:#333,stroke-width:1px,color:black
    
    %% 中止ルートを赤色の破線にする