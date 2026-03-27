import Foundation

struct Note: Identifiable, Hashable, Sendable {
    let id: UUID
    let workspaceID: UUID
    let title: String
    let body: String
    let updatedAt: Date
}
