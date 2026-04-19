# Git 運用ルール・ワークフロー

このプロジェクトでは、機能追加、バグ修正、およびドキュメント更新において以下のブランチ戦略（GitHub Flow をベースとした運用）を採用します。

## 1. ブランチの役割

| ブランチ名 | 役割 | 備考 |
| :--- | :--- | :--- |
| `main` | **本番用ブランチ** | 常に動作が安定している状態を維持する。直接コミット禁止。 |
| `develop` | **開発用ブランチ** | 次回リリースのための最新コード。ここから各機能ブランチを切る。 |
| `feature/` | **機能追加** | `feature/#10-add-audio` のようにIssue番号を含めて作成。 |
| `docs/` | **ドキュメント更新** | `docs/#5-update-readme` のように作成。 |
| `fix/` | **バグ修正** | `fix/#20-fix-tts-bug` のように作成。 |
| `chore/` | **雑務・設定変更** | CI設定やテンプレートの追加など。 |

---

## 2. 開発サイクル図 (Mermaid)

```mermaid
gitGraph
    commit id: "Initial commit"
    branch develop
    checkout develop
    commit id: "Setup project"
    
    %% ドキュメント更新の例（名前を引用符で囲む）
    branch "docs/#1-concept"
    checkout "docs/#1-concept"
    commit id: "Edit docs"
    checkout develop
    merge "docs/#1-concept" id: "Merge PR #1"
    
    %% 機能開発の例
    branch "feature/#10-word-list"
    checkout "feature/#10-word-list"
    commit id: "Add WordList"
    commit id: "Add logic"
    checkout develop
    merge "feature/#10-word-list" id: "Merge PR #10"
    
    %% 本番リリース
    checkout main
    merge develop id: "Release v1.0.0" tag: "v1.0.0"