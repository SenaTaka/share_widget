# 実装進捗チェックリスト

最終更新: 2026-03-27

## 主要機能

- [x] ノート一覧表示（作成・削除を含む）
- [x] ノート編集画面（PencilKit 描画）
- [x] 描画の遅延自動保存（2秒）
- [x] 画面離脱時の強制保存
- [x] 同期状態バッジ表示（Idle / Saving / Synced / Error）
- [x] ノートの「ウィジェット固定」操作（一覧からピン留め）
- [x] ワークスペース作成・編集・アーカイブ
- [x] 共有招待 / 参加導線
- [x] 競合解決 UI（再読込 / 上書き）
- [x] 実ウィジェット Extension へのデータ受け渡し（App Group manifest + thumbnail キャッシュ生成）

## Phase 1 (MVP) の実装 ✅

- [x] `Note` モデルに `isPinnedToWidget` を追加
- [x] `NoteRepository` にピン留め関連 API を追加
- [x] In-memory リポジトリで「常に1件だけピン留め」制約を実装
- [x] ノート一覧でピン状態の可視化（ピンアイコン）
- [x] ノート一覧でスワイプ操作からピン留め可能に変更
- [x] App Group 向け `pinned_note_manifest.json` とサムネイル PNG の書き出しを実装
- [x] ピン留め変更 / ノート保存 / タイトル更新時にウィジェットキャッシュを再生成

## Phase 2 (共同編集基盤) の実装 ✅

### ワークスペース管理
- [x] Workspace モデルの完全実装（メンバー、権限、タイムスタンプ）
- [x] WorkspaceMember と WorkspacePermission モデル
- [x] WorkspaceRepository プロトコルの拡張（CRUD 操作）
- [x] InMemoryWorkspaceRepository の Actor ベース実装
- [x] WorkspaceListViewModel の async メソッド実装
- [x] WorkspaceListScreen UI の完全実装
  - [x] ワークスペース作成ダイアログ
  - [x] ワークスペース編集（スワイプアクション）
  - [x] ワークスペースアーカイブ（スワイプアクション）
  - [x] ワークスペース削除（スワイプアクション）
  - [x] メンバー数と共有状態の表示

### 共有招待フロー
- [x] ShareInvitation モデルの実装
- [x] InvitationStatus 列挙型
- [x] ShareRepository プロトコルの定義
- [x] InMemoryShareRepository の Actor ベース実装
- [x] ShareManagementViewModel の実装
- [x] ShareManagementView UI の実装
  - [x] 招待作成（権限選択付き）
  - [x] アクティブな招待の一覧表示
  - [x] 招待の取り消し
  - [x] 招待コードのクリップボードコピー
- [x] InvitationAcceptanceViewModel の実装
- [x] InvitationAcceptanceView UI の実装
  - [x] 招待コード入力
  - [x] コード検証
  - [x] 招待詳細の表示
  - [x] 招待の承諾/辞退

### 競合解決
- [x] ConflictResolution モデルの実装
- [x] ConflictVersion 構造体
- [x] ConflictResolutionAction 列挙型
- [x] ConflictResolutionViewModel の実装
- [x] ConflictResolutionView UI の実装
  - [x] 両バージョンの並列表示
  - [x] バージョンメタデータ（作成者、タイムスタンプ、リビジョン）
  - [x] 描画プレビュー
  - [x] バージョン選択機能
  - [x] 解決またはキャンセルアクション

### 同期インフラ
- [x] SyncService プロトコルの定義
- [x] RemoteChange 列挙型
- [x] SyncError 列挙型
- [x] MockSyncService の Actor ベース実装
  - [x] 同期の開始/停止
  - [x] ワークスペース同期
  - [x] ノート同期
  - [x] リモート変更ハンドラー
  - [x] 競合検出（テスト用にランダム10%）

### その他の改善
- [x] SyncState に `.syncing` と `.conflict` を追加
- [x] SyncState に `displayText` プロパティを追加
- [x] 重複モデルファイルの統合（Workspace、SyncState）
- [x] 古いファイルの削除

## 次の優先候補 (Phase 3)

1. AppDependencies の更新（新しいリポジトリの統合）
2. ナビゲーションフローの接続
3. 実際のバックエンド統合（CloudKit または カスタム API）
4. ストローク単位の同期
5. コメントとスタンプ機能
6. ノート履歴とバージョン管理
7. オフラインモードの改善

