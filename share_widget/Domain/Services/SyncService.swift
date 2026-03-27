import Foundation

protocol SyncService {
    func startSync() async throws
    func stopSync() async
    func syncWorkspace(id: UUID) async throws
    func syncNote(id: UUID) async throws
    func registerRemoteChangeHandler(_ handler: @escaping @Sendable (RemoteChange) -> Void)
    func checkForConflicts(noteID: UUID, localRevision: Int64) async throws -> ConflictResolution?
}

enum RemoteChange: Sendable {
    case workspaceUpdated(UUID)
    case workspaceDeleted(UUID)
    case noteUpdated(UUID)
    case noteDeleted(UUID)
    case memberAdded(workspaceID: UUID, member: WorkspaceMember)
    case memberRemoved(workspaceID: UUID, userID: String)
}

enum SyncError: Error, LocalizedError {
    case notConnected
    case syncFailed(String)
    case conflictDetected
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to sync service"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .conflictDetected:
            return "Conflict detected"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}
