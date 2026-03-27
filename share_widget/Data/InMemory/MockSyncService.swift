import Foundation

actor MockSyncService: SyncService {
    private var isRunning = false
    private var remoteChangeHandlers: [@Sendable (RemoteChange) -> Void] = []
    private let noteRepository: NoteRepository

    init(noteRepository: NoteRepository) {
        self.noteRepository = noteRepository
    }

    func startSync() async throws {
        isRunning = true
        // Simulate starting sync service
        print("Mock Sync Service started")
    }

    func stopSync() async {
        isRunning = false
        print("Mock Sync Service stopped")
    }

    func syncWorkspace(id: UUID) async throws {
        guard isRunning else {
            throw SyncError.notConnected
        }

        // Simulate syncing workspace
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        print("Synced workspace: \(id)")
    }

    func syncNote(id: UUID) async throws {
        guard isRunning else {
            throw SyncError.notConnected
        }

        // Simulate syncing note
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        print("Synced note: \(id)")
    }

    func registerRemoteChangeHandler(_ handler: @escaping @Sendable (RemoteChange) -> Void) {
        remoteChangeHandlers.append(handler)
    }

    func checkForConflicts(noteID: UUID, localRevision: Int64) async throws -> ConflictResolution? {
        guard isRunning else {
            throw SyncError.notConnected
        }

        // Simulate checking for conflicts
        // In a real implementation, this would check against remote server
        // For now, we'll randomly simulate conflicts (10% chance)
        let hasConflict = Int.random(in: 0..<10) == 0

        if hasConflict {
            // Simulate a conflict by creating mock conflict data
            guard let note = try await noteRepository.fetchNote(noteID: noteID) else {
                return nil
            }

            let localVersion = ConflictVersion(
                revision: localRevision,
                updatedAt: note.updatedAt,
                updatedByUserID: "local_user",
                updatedByName: "You",
                drawingData: note.drawingData
            )

            let remoteVersion = ConflictVersion(
                revision: localRevision + 1,
                updatedAt: Date().addingTimeInterval(-60), // 1 minute ago
                updatedByUserID: "remote_user",
                updatedByName: "Alice",
                drawingData: note.drawingData // In reality, this would be different
            )

            return ConflictResolution(
                noteID: noteID,
                noteTitle: note.title,
                localVersion: localVersion,
                remoteVersion: remoteVersion
            )
        }

        return nil
    }

    // Helper method to simulate remote changes (for testing)
    func simulateRemoteChange(_ change: RemoteChange) async {
        for handler in remoteChangeHandlers {
            handler(change)
        }
    }
}
