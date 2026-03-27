import Foundation

protocol ShareRepository {
    func createInvitation(workspaceID: UUID, permission: WorkspacePermission) async throws -> ShareInvitation
    func fetchInvitations(workspaceID: UUID) async throws -> [ShareInvitation]
    func fetchPendingInvitations() async throws -> [ShareInvitation]
    func acceptInvitation(invitationCode: String) async throws -> Workspace
    func declineInvitation(invitationID: UUID) async throws
    func revokeInvitation(invitationID: UUID) async throws
    func validateInvitationCode(_ code: String) async throws -> ShareInvitation?
}

enum ShareRepositoryError: Error, LocalizedError {
    case invitationNotFound
    case invitationExpired
    case invitationAlreadyUsed
    case invalidInvitationCode
    case workspaceNotFound
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .invitationNotFound:
            return "Invitation not found"
        case .invitationExpired:
            return "Invitation has expired"
        case .invitationAlreadyUsed:
            return "Invitation has already been used"
        case .invalidInvitationCode:
            return "Invalid invitation code"
        case .workspaceNotFound:
            return "Workspace not found"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}
