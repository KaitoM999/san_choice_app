# 画面遷移図 (UI Flow)

```mermaid
graph TD
    %% 画面要素の定義
    Home[<b>ホーム画面</b><br/>・言語選択<br/>・各画面への入り口]
    
    CharIntro[<b>キャラクター紹介画面</b><br/>・ロースちゃん/博士の設定確認]
    
    WordList[<b>単語一覧画面</b><br/>・辞書機能<br/>・全単語の音声確認]

    BlockSelect[<b>ブロック選択画面</b><br/>・1〜200のリスト<br/>・最高得点の表示<br/>・出題方向の切り替え]

    subgraph QuizLoop [クイズサイクル（6回繰り返し）]
        QuizMain[<b>クイズ画面</b><br/>・問題表示/TTS再生<br/>・3択選択]
        AnswerDetail[<b>詳細カード展開</b><br/>・正誤判定<br/>・品詞/例文/音声の確認]
        
        QuizMain -->|解答をタップ| AnswerDetail
        AnswerDetail -->|「次の問題へ」をタップ| QuizMain
    end

    Ad[<b>インタースティシャル広告</b><br/>※マージン確保と収益化]

    Result[<b>結果発表画面</b><br/>・スコア表示<br/>・博士の格言]

    %% メインの遷移
    Home <==> BlockSelect
    Home <==> WordList
    Home <==> CharIntro

    BlockSelect ==>|ブロックを選択して開始| QuizMain
    
    QuizLoop ==>|6問終了| Ad
    Ad ==> Result
    
    Result ==>|「一覧に戻る」| BlockSelect
    Result ==>|「ホームに戻る」| Home

    %% 中止アクション
    QuizMain -.->|左上「×」で戻る| BlockSelect

    %% スタイルの調整
    style Home fill:#d32f2f,stroke:#333,stroke-width:2px,color:white
    style BlockSelect fill:#1976d2,stroke:#333,stroke-width:2px,color:white
    style QuizMain fill:#388e3c,stroke:#333,stroke-width:2px,color:white
    style Result fill:#fbc02d,stroke:#333,stroke-width:2px,color:black
    style Ad fill:#757575,stroke:#333,stroke-width:2px,color:white