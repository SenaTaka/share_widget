import Foundation

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

    init(
        id: UUID = UUID(),
        workspaceID: UUID,
        workspaceName: String,
        inviterUserID: String,
        inviterName: String,
        invitedUserID: String? = nil,
        permission: WorkspacePermission = .readWrite,
        status: InvitationStatus = .pending,
        createdAt: Date = Date(),
        expiresAt: Date = Date().addingTimeInterval(7 * 24 * 60 * 60), // 7 days
        invitationCode: String = UUID().uuidString
    ) {
        self.id = id
        self.workspaceID = workspaceID
        self.workspaceName = workspaceName
        self.inviterUserID = inviterUserID
        self.inviterName = inviterName
        self.invitedUserID = invitedUserID
        self.permission = permission
        self.status = status
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.invitationCode = invitationCode
    }
}

enum InvitationStatus: String, Codable, Sendable {
    case pending
    case accepted
    case declined
    case expired
    case revoked
}
