# Share Widget - 共同手書きメモアプリ

<div align="center">

**iOS用の共同編集可能な手書きメモアプリ - ホーム画面ウィジェットで最新状態を即座に確認**

[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue.svg)]()
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-26.0.1%2B-blue.svg)]()

</div>

---

## 📖 日本語版 / Japanese Version

[日本語のREADMEはこちら](#japanese-readme)

---

## 🌟 Overview

Share Widget is a collaborative handwritten memo app for iOS that combines the freedom of handwriting with the convenience of real-time collaboration. Pin your most important notes to your home screen widget for instant access to the latest updates without opening the app.

### Key Features

- ✏️ **Natural Handwriting**: Create notes using Apple Pencil or finger with PencilKit
- 👥 **Collaborative Editing**: Share workspaces with family, friends, or teams
- 📱 **Home Screen Widgets**: View the latest note updates directly on your home screen
- 🔄 **Real-time Sync**: Changes sync automatically across all devices
- 💾 **Smart Auto-save**: Automatic saving with 2-second debounce to prevent excessive writes
- 📌 **Pin to Widget**: Feature one note on your home screen for quick access
- 🎨 **Rich Drawing Tools**: Pen, marker, and eraser tools with full PencilKit support

### Use Cases

- 📝 Shared shopping lists for families
- 💬 Handwritten message boards for couples and friends
- 🎓 Collaborative study notes for students
- 🎯 Team whiteboard alternative for small groups
- 📋 Quick sketches and brainstorming sessions

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│           Presentation Layer (SwiftUI)                  │
│  WorkspaceListView ← NoteEditorView ← PencilCanvasView  │
│         ↓                    ↓                           │
│  WorkspaceListViewModel   NoteEditorViewModel           │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
┌──────────────▼──────────────────────▼───────────────────┐
│            Domain Layer (Business Logic)                │
│  SaveDrawingUseCase  RefreshWidgetUseCase               │
│              ↓                      ↓                    │
│  NoteRepository (Protocol)  WorkspaceRepository         │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
┌──────────────▼──────────────────────▼───────────────────┐
│          Data Layer (Repositories)                      │
│  InMemoryNoteRepository (Actor)                         │
│  InMemoryWorkspaceRepository                            │
└──────────────┬──────────────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────────────┐
│    Widget Bridge Layer (App Group Integration)          │
│  WidgetBridge (AppGroupWidgetBridge)                    │
│  - Manifest JSON generation                             │
│  - Thumbnail image rendering                            │
│  - Widget timeline updates                              │
└─────────────────────────────────────────────────────────┘
```

### Layers

1. **Presentation Layer**: SwiftUI views and ViewModels for UI state management
2. **Domain Layer**: Business logic with use cases, domain models, and repository interfaces
3. **Data Layer**: Repository implementations with thread-safe Actor-based storage
4. **Widget Bridge Layer**: App Group integration for widget data sharing

---

## 🗂️ Project Structure

```
share_widget/
├── share_widget/                 # Main app source code
│   ├── App/
│   │   ├── AppDependencies.swift       # Dependency injection container
│   │   └── RootView.swift              # App root navigation
│   ├── Domain/                   # Business logic layer
│   │   ├── Models/
│   │   │   ├── Workspace.swift         # Workspace domain model
│   │   │   ├── Note.swift              # Note domain model
│   │   │   └── SyncState.swift         # Sync status enum
│   │   ├── Repositories/
│   │   │   ├── NoteRepository.swift    # Note protocol interface
│   │   │   └── WorkspaceRepository.swift # Workspace protocol interface
│   │   └── UseCases/
│   │       ├── SaveDrawingUseCase.swift    # Drawing save logic
│   │       └── RefreshWidgetUseCase.swift  # Widget update logic
│   ├── Data/                     # Data layer
│   │   ├── InMemory/
│   │   │   └── InMemoryNoteRepository.swift # Actor-based note repository
│   │   └── InMemoryWorkspaceRepository.swift # Workspace store
│   ├── Presentation/             # UI layer
│   │   ├── WorkspaceList/
│   │   │   ├── WorkspaceListView.swift     # Workspace list UI
│   │   │   └── WorkspaceListViewModel.swift # Workspace list logic
│   │   └── NoteEditor/
│   │       ├── NoteEditorView.swift        # Note editing UI
│   │       ├── NoteEditorViewModel.swift   # Note editor logic
│   │       └── PencilCanvasView.swift      # PencilKit integration
│   ├── WidgetBridge/             # Widget integration layer
│   │   └── WidgetBridge.swift    # App Group manifest & thumbnail gen
│   ├── ContentView.swift          # Entry point wrapper
│   └── share_widgetApp.swift      # SwiftUI app entry
├── docs/
│   ├── compatibility.md           # iOS version compatibility notes
│   └── progress_checklist.md      # Implementation progress tracker
└── todo.txt                       # Comprehensive design document
```

---

## 🚀 Getting Started

### Prerequisites

- **macOS**: macOS Sonoma or later
- **Xcode**: 26.0.1 or later
- **iOS**: iOS 17.0 or later (deployment target)
- **Swift**: 6.0 or later
- **Apple Pencil** (optional, but recommended for best experience)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SenaTaka/share_widget.git
   cd share_widget
   ```

2. **Open the project in Xcode**:
   ```bash
   open share_widget.xcodeproj
   ```

3. **Select your target device**: Choose an iOS device or simulator (iOS 17.0+) from Xcode's scheme selector

4. **Build and run**: Press `⌘ + R` or click the Play button in Xcode

### Configuration

No additional configuration is required for the basic functionality. The app uses in-memory storage for the MVP phase.

---

## 💻 Development

### Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| UI Framework | SwiftUI + PencilKit | Modern iOS interface + handwriting |
| State Management | @Published, @StateObject | Reactive state management |
| Concurrency | Swift Actors, async/await | Thread-safe data + modern async |
| Storage | In-memory (MVP) | Quick development iteration |
| Widgets | WidgetKit, App Group | Home screen integration |
| Architecture | Clean Architecture + MVVM | Separation of concerns |
| Build System | Xcode 26.0.1 | Modern Swift development |

### Key Design Principles

1. **Local-first**: Drawings saved locally first, then synced
2. **Debounced Autosave**: 2-second delay before persisting to avoid excessive saves
3. **Forced Save on Exit**: Ensures no work is lost when leaving the editor
4. **Widget Cache Separation**: Display data isolated from editing data
5. **Actor-based Threading**: InMemoryNoteRepository uses Actor for thread-safe access
6. **Protocol-driven Repositories**: Easy to swap in-memory for real implementations

### Building the Project

```bash
# Build for iOS Simulator
xcodebuild -scheme share_widget -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build for Device
xcodebuild -scheme share_widget -sdk iphoneos build

# Clean build folder
xcodebuild clean -scheme share_widget
```

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI naming conventions
- Keep functions focused and single-purpose
- Use meaningful variable names
- Add comments only for complex logic

---

## 📚 Features Documentation

### Current Features (v0.1 MVP)

#### ✅ Note Management
- Create, read, update, and delete notes
- Edit note titles
- View all notes in a workspace
- Pin one note to the home screen widget

#### ✅ Drawing Editor
- PencilKit-based handwriting with full tool support
- Pen, marker, and eraser tools
- Supports Apple Pencil and finger input
- Automatic 2-second debounce save
- Force save when leaving the editor
- Real-time sync state badges (Idle, Saving, Synced, Error)

#### ✅ Widget Integration
- Pin/unpin notes to home screen widget (one at a time)
- Automatic thumbnail generation for widgets
- JSON manifest for widget data
- App Group integration for data sharing
- Widget refresh on note changes
- **Multiple widget sizes**: Small, Medium, Large, Extra Large (iPad)
- **Lock Screen widgets**: Circular, Rectangular, Inline (iOS 16+)

### New Features (v0.2 - Phase 2)

#### ✅ Workspace Management
- Create, edit, and delete workspaces
- Archive/unarchive workspaces
- View workspace members and sharing status
- Organize notes by workspace
- Last updated timestamps

#### ✅ Collaboration Features
- Share workspace invitations with permission levels (Owner, Read/Write, Read Only)
- Generate unique invitation codes (7-day expiration)
- Accept/decline workspace invitations
- View active invitation status
- Revoke pending invitations
- Member management with permissions

#### ✅ Conflict Resolution
- Detect editing conflicts between users
- Side-by-side version comparison UI
- View version metadata (author, timestamp, revision)
- Drawing preview for both versions
- Choose to keep local or remote version
- Cancel conflict resolution

#### ✅ Synchronization Infrastructure
- Mock sync service for testing
- Remote change event system
- Workspace and note sync operations
- Conflict detection (10% random for testing)
- Start/stop sync controls

### Planned Features (Phase 3)

#### 🎨 Advanced Features
- Stroke-level synchronization
- Comments and stamps
- Note history and undo/redo
- Handwriting search
- Multiple widget configurations
- Real backend integration (CloudKit/custom API)

---

## 🧪 Testing

### Running Tests

Currently, the project is in MVP phase with in-memory storage. Testing infrastructure will be added as the project evolves.

```bash
# Run all tests
xcodebuild test -scheme share_widget -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -scheme share_widget -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:share_widgetTests/TestClassName
```

---

## 📱 Widget Setup

### Home Screen Widget

1. **Pin a note**: In the note list, swipe left on a note and tap "ウィジェットに表示"
2. **Add widget to home screen**: Long-press on your home screen → tap the "+" button → search for "手書きメモ" → select widget size (Small/Medium/Large) → tap "Add Widget"
3. **View your note**: The pinned note will appear on your home screen with its thumbnail
4. **Open note**: Tap the widget to open the note in the app

### Lock Screen Widget (iOS 16+)

1. **Pin a note** in the app first
2. **Customize lock screen**: Long-press on your lock screen → tap "Customize" → select Lock Screen
3. **Add widget**: Tap the widget area → search for "手書きメモ" → choose from:
   - **Circular**: Round thumbnail preview
   - **Rectangular**: Thumbnail with title and timestamp
   - **Inline**: Text-only with note title
4. **Done**: Tap "Done" to save

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Commit your changes**: `git commit -m 'Add some feature'`
4. **Push to the branch**: `git push origin feature/your-feature-name`
5. **Open a Pull Request**

### Development Guidelines

- Follow the existing architecture patterns (Clean Architecture + MVVM)
- Write clear commit messages
- Keep changes focused and atomic
- Add comments for complex logic
- Update documentation for new features
- Ensure code compiles without warnings
- Test on multiple iOS versions (iOS 17+)

---

## 📄 Documentation

- **Design Document**: See [todo.txt](./todo.txt) for comprehensive design specifications (Japanese)
- **Workspace CRUD Implementation**: See [docs/workspace_crud_implementation.md](./docs/workspace_crud_implementation.md) for Phase 2 features
- **Compatibility**: See [docs/compatibility.md](./docs/compatibility.md) for iOS version compatibility
- **Progress**: See [docs/progress_checklist.md](./docs/progress_checklist.md) for implementation status

---

## 🔒 Security

- Sharing based on invitation system
- Display cache separated from editing data
- Widget accesses minimal data required for display
- iCloud-based sharing (when implemented)

---

## 📈 Roadmap

### Phase 1 - MVP ✅
- [x] Note CRUD operations
- [x] PencilKit drawing integration
- [x] Autosave mechanism
- [x] Widget pin/unpin functionality
- [x] Widget cache generation

### Phase 2 - Collaboration Foundation ✅
- [x] Workspace CRUD and management
- [x] Share invitation flow
- [x] Conflict resolution UI
- [x] Mock synchronization implementation

### Phase 3 - Future Enhancements
- [ ] Real backend integration (CloudKit or custom API)
- [ ] Stroke-level synchronization
- [ ] Comments and annotations
- [ ] Note history and version control
- [ ] Advanced widget configurations
- [ ] Fine-grained permissions
- [ ] Offline mode improvements

---

## 📝 License

This project does not currently have a specified license. Please contact the repository owner for usage rights and permissions.

---

## 👥 Authors

- **SenaTaka** - [GitHub Profile](https://github.com/SenaTaka)

---

## 🙏 Acknowledgments

- Apple PencilKit for the drawing framework
- Apple WidgetKit for home screen integration
- SwiftUI for modern UI development

---

## 📞 Contact & Support

For questions, issues, or feature requests:
- Open an issue on [GitHub Issues](https://github.com/SenaTaka/share_widget/issues)
- Check existing documentation in the `docs/` directory

---

<a name="japanese-readme"></a>

# 📖 日本語版 README

## 概要

Share Widgetは、手書きの自由度と共同編集の便利さを組み合わせたiOS用の手書きメモアプリです。大切なノートをホーム画面ウィジェットに固定することで、アプリを開かずに最新の更新内容を即座に確認できます。

## 主な機能

- ✏️ **自然な手書き**: Apple Pencilまたは指でPencilKitを使用してノートを作成
- 👥 **共同編集**: 家族、友人、チームとワークスペースを共有
- 📱 **ホーム画面ウィジェット**: ホーム画面で最新のノート更新を直接表示
- 🔄 **リアルタイム同期**: すべてのデバイス間で自動的に変更を同期
- 💾 **スマート自動保存**: 2秒のデバウンスで過剰な書き込みを防止
- 📌 **ウィジェットに固定**: 1つのノートをホーム画面に表示して素早くアクセス
- 🎨 **豊富な描画ツール**: ペン、マーカー、消しゴムなど、PencilKitの全機能をサポート

## 想定ユースケース

- 📝 家族の共有買い物リスト
- 💬 カップルや友人への手書き伝言板
- 🎓 学生同士の共同学習ノート
- 🎯 小規模チームのホワイトボード代替
- 📋 素早いスケッチやブレインストーミング

## 技術スタック

- **UI**: SwiftUI + PencilKit
- **アーキテクチャ**: クリーンアーキテクチャ + MVVM
- **並行処理**: Swift Actor, async/await
- **ストレージ**: インメモリ（MVP版）
- **ウィジェット**: WidgetKit, App Group
- **対象OS**: iOS 17.0以降
- **開発環境**: Xcode 26.0.1以上、Swift 6.0以上

## セットアップ

1. リポジトリをクローン:
   ```bash
   git clone https://github.com/SenaTaka/share_widget.git
   cd share_widget
   ```

2. Xcodeでプロジェクトを開く:
   ```bash
   open share_widget.xcodeproj
   ```

3. ターゲットデバイスを選択してビルド（⌘ + R）

## プロジェクト構造

プロジェクトはクリーンアーキテクチャに基づいて以下の層に分かれています：

- **Presentation層**: SwiftUIビューとViewModel（UI状態管理）
- **Domain層**: ビジネスロジック（ユースケース、ドメインモデル、リポジトリインターフェース）
- **Data層**: リポジトリ実装（スレッドセーフなActorベースストレージ）
- **Widget Bridge層**: ウィジェットデータ共有のためのApp Group統合

## 開発の進捗状況

### 実装済み（v0.1 MVP）
- [x] ノートのCRUD操作
- [x] PencilKit描画統合
- [x] 自動保存メカニズム（2秒デバウンス）
- [x] ウィジェットのピン留め機能
- [x] ウィジェットキャッシュ生成
- [x] 同期状態バッジ表示

### 予定機能
- [ ] ワークスペースのCRUDと管理
- [ ] 共有招待フロー
- [ ] 競合解決UI
- [ ] 実際の同期実装
- [ ] ストローク単位の同期
- [ ] コメントとスタンプ
- [ ] ノート履歴
- [ ] 高度なウィジェット構成

## ウィジェットの設定方法

### ホーム画面ウィジェット

1. **ノートを固定**: ノート一覧でノートを左スワイプし、「ウィジェットに表示」をタップ
2. **ウィジェットを追加**: ホーム画面を長押し → 「+」ボタンをタップ → "手書きメモ"を検索 → ウィジェットサイズを選択（Small/Medium/Large） → 「ウィジェットを追加」
3. **ノートを表示**: 固定したノートがサムネイル付きでホーム画面に表示されます
4. **ノートを開く**: ウィジェットをタップしてアプリ内でノートを開きます

### ロック画面ウィジェット（iOS 16+）

1. アプリで先にノートを**ピン留め**
2. **ロック画面をカスタマイズ**: ロック画面を長押し → 「カスタマイズ」→ ロック画面を選択
3. **ウィジェットを追加**: ウィジェットエリアをタップ → "手書きメモ"を検索 → 以下から選択:
   - **Circular（丸型）**: 丸いサムネイルプレビュー
   - **Rectangular（長方形）**: サムネイル＋タイトル＋更新時間
   - **Inline（インライン）**: ノートタイトルのみのテキスト表示
4. **完了**: 「完了」をタップして保存

## ドキュメント

- **設計書**: [todo.txt](./todo.txt) - 包括的な設計仕様書（693行）
- **互換性**: [docs/compatibility.md](./docs/compatibility.md) - iOSバージョン互換性ポリシー
- **進捗**: [docs/progress_checklist.md](./docs/progress_checklist.md) - 実装状況チェックリスト

## コントリビューション

コントリビューションを歓迎します！以下のガイドラインに従ってください：

1. リポジトリをフォーク
2. フィーチャーブランチを作成: `git checkout -b feature/your-feature-name`
3. 変更をコミット: `git commit -m 'Add some feature'`
4. ブランチにプッシュ: `git push origin feature/your-feature-name`
5. プルリクエストを作成

## お問い合わせ

質問、問題、機能リクエストについては：
- [GitHub Issues](https://github.com/SenaTaka/share_widget/issues)でissueを作成
- `docs/`ディレクトリの既存ドキュメントを確認

---

**Made with ❤️ for the collaborative handwriting community**

---

## 🗓️ 今後の計画（2026-03-27 時点）

### P0（今週必須）
- [x] **SW-001**: 投稿モデルをマルチタイプ対応（`entryType`, `photoReference`, `messageText`, `authorUserID` 追加、`drawingData` 後方互換維持）
- [x] **SW-002**: `NoteRepository` に写真投稿APIを追加（`createPhotoMessageEntry`, `updateMessage` ほか）
- [x] **SW-003**: `InMemoryNoteRepository` を新API対応（写真投稿の作成/更新/削除、時系列整列、ピン留め1件制約維持）
- [x] **SW-004**: 投稿編集画面を「手書き / 写真＋一言」切替UI化
- [x] **SW-005**: 一覧画面を投稿タイプ別タイムライン表示へ更新
- [x] **SW-006**: ウィジェットを投稿タイプ別プレビュー対応

### P1（今週後半〜次週）
- [ ] **SW-007**: 共有権限に応じた投稿制御（readOnly投稿不可、readWrite投稿可）
- [ ] **SW-008**: 招待→参加→投稿までのE2E導線確認

### P2（余力）
- [ ] **SW-009**: 投稿バリデーション強化（文字数制限、空投稿防止、画像未選択ガード）
- [ ] **SW-010**: 表示改善（日付区切り、投稿者ラベル、リアクション準備）

### 実装順（依存関係）
1. SW-001 → SW-002 → SW-003
2. SW-004 / SW-005（並行）
3. SW-006
4. SW-007 / SW-008
5. SW-009 / SW-010

### チケットテンプレート（運用）
```md
Title: SW-xxx ...

Background:

Scope:

Out of Scope:

AC (Acceptance Criteria):

Test Points:

Risk:
```
