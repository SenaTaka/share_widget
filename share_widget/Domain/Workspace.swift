import Foundation

struct Workspace: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let syncState: SyncState
}
