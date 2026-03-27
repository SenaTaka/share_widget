import Foundation

struct InMemoryWorkspaceRepository: WorkspaceRepository {
    func fetchWorkspaces() -> [Workspace] {
        [
            Workspace(id: UUID(), name: "Personal", syncState: .synced),
            Workspace(id: UUID(), name: "Team Wiki", syncState: .syncing),
            Workspace(id: UUID(), name: "Ideas", syncState: .failed),
        ]
    }
}
