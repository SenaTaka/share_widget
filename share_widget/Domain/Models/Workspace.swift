import Foundation

struct Workspace: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    var name: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var ownerUserID: String
    var isShared: Bool
    var members: [WorkspaceMember]

    init(
        id: UUID = UUID(),
        name: String,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ownerUserID: String = "local_user",
        isShared: Bool = false,
        members: [WorkspaceMember] = []
    ) {
        self.id = id
        self.name = name
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ownerUserID = ownerUserID
        self.isShared = isShared
        self.members = members
    }
}

struct WorkspaceMember: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let userID: String
    let displayName: String
    let permission: WorkspacePermission
    let joinedAt: Date

    init(
        id: UUID = UUID(),
        userID: String,
        displayName: String,
        permission: WorkspacePermission = .readWrite,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.displayName = displayName
        self.permission = permission
        self.joinedAt = joinedAt
    }
}

enum WorkspacePermission: String, Codable, Sendable {
    case owner
    case readWrite
    case readOnly
}
