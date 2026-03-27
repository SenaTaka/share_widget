# Workspace CRUD and Management Implementation

This document describes the implementation of Workspace CRUD operations, Share Invitation flow, Conflict Resolution UI, and Real Synchronization features added to the Share Widget app.

## Overview

This implementation adds four major feature sets:
1. **Workspace CRUD Operations** - Create, Read, Update, Archive, and Delete workspaces
2. **Share Invitation Flow** - Invite users to collaborate on workspaces
3. **Conflict Resolution UI** - Handle editing conflicts between collaborators
4. **Real Synchronization** - Mock sync service for testing collaboration features

## Architecture

### Domain Models

#### Workspace Model (`Domain/Models/Workspace.swift`)
```swift
struct Workspace: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    var name: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var ownerUserID: String
    var isShared: Bool
    var members: [WorkspaceMember]
}
```

Key features:
- Full workspace metadata including creation/update times
- Member management with permissions
- Archive support (soft delete)
- Shared workspace indicator

#### WorkspaceMember Model
```swift
struct WorkspaceMember: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let userID: String
    let displayName: String
    let permission: WorkspacePermission
    let joinedAt: Date
}

enum WorkspacePermission: String, Codable, Sendable {
    case owner
    case readWrite
    case readOnly
}
```

#### ShareInvitation Model (`Domain/Models/ShareInvitation.swift`)
```swift
struct ShareInvitation: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let workspaceID: UUID
    let workspaceName: String
    let inviterUserID: String
    let inviterName: String
    let invitedUserID: String?
    let permission: WorkspacePermission
    let status: InvitationStatus
    let createdAt: Date
    let expiresAt: Date
    let invitationCode: String
}

enum InvitationStatus: String, Codable, Sendable {
    case pending
    case accepted
    case declined
    case expired
    case revoked
}
```

Features:
- Unique invitation codes
- 7-day expiration by default
- Permission-based invitations
- Status tracking

#### ConflictResolution Model (`Domain/Models/ConflictResolution.swift`)
```swift
struct ConflictResolution: Identifiable, Equatable, Sendable {
    let id: UUID
    let noteID: UUID
    let noteTitle: String
    let localVersion: ConflictVersion
    let remoteVersion: ConflictVersion
    let detectedAt: Date
}

struct ConflictVersion: Equatable, Sendable {
    let revision: Int64
    let updatedAt: Date
    let updatedByUserID: String
    let updatedByName: String
    let drawingData: Data
}
```

#### Enhanced SyncState (`Domain/Models/SyncState.swift`)
Added new states:
- `.syncing` - Synchronizing with remote
- `.conflict` - Conflict detected
- `displayText` property for UI display

### Repositories

#### WorkspaceRepository (`Domain/WorkspaceRepository.swift`)
Protocol for workspace operations:
```swift
protocol WorkspaceRepository {
    func fetchWorkspaces() async throws -> [Workspace]
    func fetchWorkspace(id: UUID) async throws -> Workspace?
    func createWorkspace(name: String) async throws -> Workspace
    func updateWorkspace(id: UUID, name: String) async throws -> Workspace
    func archiveWorkspace(id: UUID) async throws
    func unarchiveWorkspace(id: UUID) async throws
    func deleteWorkspace(id: UUID) async throws
}
```

#### ShareRepository (`Domain/Repositories/ShareRepository.swift`)
Protocol for invitation management:
```swift
protocol ShareRepository {
    func createInvitation(workspaceID: UUID, permission: WorkspacePermission) async throws -> ShareInvitation
    func fetchInvitations(workspaceID: UUID) async throws -> [ShareInvitation]
    func fetchPendingInvitations() async throws -> [ShareInvitation]
    func acceptInvitation(invitationCode: String) async throws -> Workspace
    func declineInvitation(invitationID: UUID) async throws
    func revokeInvitation(invitationID: UUID) async throws
    func validateInvitationCode(_ code: String) async throws -> ShareInvitation?
}
```

#### SyncService (`Domain/Services/SyncService.swift`)
Protocol for synchronization:
```swift
protocol SyncService {
    func startSync() async throws
    func stopSync() async
    func syncWorkspace(id: UUID) async throws
    func syncNote(id: UUID) async throws
    func registerRemoteChangeHandler(_ handler: @escaping @Sendable (RemoteChange) -> Void)
    func checkForConflicts(noteID: UUID, localRevision: Int64) async throws -> ConflictResolution?
}
```

### Implementations

All implementations use Swift Actors for thread-safe concurrent access:

1. **InMemoryWorkspaceRepository** (`Data/InMemoryWorkspaceRepository.swift`)
   - Actor-based thread-safe storage
   - Sample workspaces on initialization
   - Full CRUD operations

2. **InMemoryShareRepository** (`Data/InMemory/InMemoryShareRepository.swift`)
   - Actor-based thread-safe storage
   - Invitation lifecycle management
   - Code validation and expiration checking

3. **MockSyncService** (`Data/InMemory/MockSyncService.swift`)
   - Simulates network latency (0.5s)
   - 10% random conflict generation for testing
   - Remote change event system

## User Interface

### Workspace Management

#### WorkspaceListScreen (`Presentation/WorkspaceListScreen.swift`)
Features:
- Display all non-archived workspaces
- Sort by last updated (newest first)
- Create new workspace (+ button)
- Swipe actions:
  - **Left swipe (leading)**: Edit workspace name
  - **Right swipe (trailing)**: Archive or Delete workspace
- Display workspace metadata:
  - Shared status icon
  - Member count
  - Last updated time

#### WorkspaceRow Component
Displays:
- Workspace name (headline)
- Shared indicator icon
- "Updated X ago" relative time
- Member count

### Share Management

#### ShareManagementView (`Presentation/ShareManagement/ShareManagementView.swift`)
Features:
- Create invitation button
- Permission selection dialog (Read & Write / Read Only)
- List of active invitations with status badges
- Revoke invitation action
- Invitation code sheet with copy-to-clipboard

Components:
- **InvitationRow**: Shows invitation details, status, and expiration
- **StatusBadge**: Color-coded status indicator
- **InvitationCodeSheet**: Displays generated code with copy function

### Invitation Acceptance

#### InvitationAcceptanceView (`Presentation/InvitationAcceptance/InvitationAcceptanceView.swift`)
Multi-step flow:
1. **Code Input**: Enter invitation code
2. **Validation**: Verify code is valid and not expired
3. **Details Review**: Show workspace name, inviter, permission, expiration
4. **Accept/Decline**: User decision
5. **Success**: Confirmation and navigation

Components:
- **InfoRow**: Icon + label + value display
- Form validation and error handling
- Progress indicators during async operations

### Conflict Resolution

#### ConflictResolutionView (`Presentation/ConflictResolution/ConflictResolutionView.swift`)
Features:
- Warning header with conflict explanation
- Side-by-side version comparison
- Version metadata display:
  - Author name
  - Update timestamp (relative)
  - Revision number
- Drawing preview for both versions
- Select-to-keep interaction
- Resolve or Cancel actions

Components:
- **VersionCard**: Selectable card showing version details
- **InfoLabel**: Icon + text for metadata
- **DrawingPreview**: PencilKit drawing image preview

## Usage Examples

### Creating a Workspace

```swift
let viewModel = WorkspaceListViewModel(
    workspaceRepository: InMemoryWorkspaceRepository()
)

Task {
    await viewModel.createWorkspace(name: "My New Workspace")
}
```

### Sharing a Workspace

```swift
let shareRepo = InMemoryShareRepository(workspaceRepository: workspaceRepo)
let viewModel = ShareManagementViewModel(
    shareRepository: shareRepo,
    workspaceID: workspaceID
)

Task {
    await viewModel.createInvitation(permission: .readWrite)
    // generatedInvitationCode is now available
}
```

### Accepting an Invitation

```swift
let viewModel = InvitationAcceptanceViewModel(shareRepository: shareRepo)
viewModel.invitationCode = "ABC-123-DEF"

Task {
    await viewModel.validateCode()
    if viewModel.invitation != nil {
        await viewModel.acceptInvitation()
        // acceptedWorkspace is now available
    }
}
```

### Resolving Conflicts

```swift
ConflictResolutionView(conflict: conflict) { action in
    switch action {
    case .keepLocal:
        // Save local version
    case .keepRemote:
        // Fetch and save remote version
    case .cancel:
        // Do nothing
    }
}
```

## Testing

All new features include SwiftUI previews for visual testing:

```swift
#Preview {
    let workspaceRepo = InMemoryWorkspaceRepository()
    return WorkspaceListScreen(
        viewModel: WorkspaceListViewModel(workspaceRepository: workspaceRepo)
    )
}
```

## Integration Points

To fully integrate these features into the app:

1. **Update AppDependencies** to include:
   - WorkspaceRepository
   - ShareRepository
   - SyncService

2. **Add Navigation**:
   - Connect WorkspaceListScreen to main navigation
   - Add share button in workspace detail views
   - Add invitation acceptance from deep links

3. **Integrate Conflict Resolution**:
   - Call `syncService.checkForConflicts()` before note saves
   - Present ConflictResolutionView when conflicts detected
   - Handle user's resolution choice

4. **Connect Sync Service**:
   - Start sync on app launch
   - Register remote change handlers
   - Update UI when remote changes arrive

## Future Enhancements

1. **Real Backend Integration**:
   - Replace mock implementations with actual API calls
   - Use CloudKit or custom backend
   - Implement real-time WebSocket connections

2. **Advanced Features**:
   - Stroke-level synchronization
   - Operational Transform (OT) or CRDT for automatic conflict resolution
   - Multiple workspace support per user
   - Workspace templates

3. **UI Improvements**:
   - Animated transitions
   - Better error handling and recovery
   - Offline mode indicators
   - Pull-to-refresh

## File Structure

```
share_widget/
├── Domain/
│   ├── Models/
│   │   ├── Workspace.swift
│   │   ├── ShareInvitation.swift
│   │   ├── ConflictResolution.swift
│   │   └── SyncState.swift
│   ├── Repositories/
│   │   ├── WorkspaceRepository.swift
│   │   ├── ShareRepository.swift
│   │   └── NoteRepository.swift
│   └── Services/
│       └── SyncService.swift
├── Data/
│   ├── InMemoryWorkspaceRepository.swift
│   └── InMemory/
│       ├── InMemoryNoteRepository.swift
│       ├── InMemoryShareRepository.swift
│       └── MockSyncService.swift
└── Presentation/
    ├── WorkspaceListScreen.swift
    ├── WorkspaceListViewModel.swift
    ├── ShareManagement/
    │   ├── ShareManagementView.swift
    │   └── ShareManagementViewModel.swift
    ├── InvitationAcceptance/
    │   ├── InvitationAcceptanceView.swift
    │   └── InvitationAcceptanceViewModel.swift
    └── ConflictResolution/
        ├── ConflictResolutionView.swift
        └── ConflictResolutionViewModel.swift
```

## Clean Architecture Principles

This implementation follows Clean Architecture:

1. **Domain Layer** (innermost):
   - Pure business logic
   - Protocol definitions
   - No dependencies on outer layers

2. **Data Layer**:
   - Implements domain protocols
   - Actor-based for thread safety
   - In-memory storage for MVP

3. **Presentation Layer** (outermost):
   - SwiftUI views and ViewModels
   - Depends on domain protocols
   - No direct dependency on implementations

Benefits:
- Easy to test (mock implementations)
- Easy to swap implementations (e.g., CloudKit instead of in-memory)
- Clear separation of concerns
- Maintainable and scalable

## Thread Safety

All repository and service implementations use Swift Actors:

```swift
actor InMemoryWorkspaceRepository: WorkspaceRepository {
    private var workspaces: [Workspace] = []
    // Actor ensures thread-safe access
}
```

This ensures:
- No data races
- Safe concurrent access
- Automatic serialization of mutations

## Error Handling

Each repository defines its own error types:

```swift
enum WorkspaceRepositoryError: Error, LocalizedError {
    case workspaceNotFound
    case invalidWorkspaceName
    case archiveError
    case deleteError
}

enum ShareRepositoryError: Error, LocalizedError {
    case invitationNotFound
    case invitationExpired
    case invitationAlreadyUsed
    case invalidInvitationCode
    case workspaceNotFound
    case permissionDenied
}
```

ViewModels catch errors and expose them via `@Published` properties for UI display.
