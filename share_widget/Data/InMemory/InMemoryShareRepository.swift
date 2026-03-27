import Foundation

actor InMemoryShareRepository: ShareRepository {
    private var invitations: [ShareInvitation] = []
    private let workspaceRepository: WorkspaceRepository

    init(workspaceRepository: WorkspaceRepository) {
        self.workspaceRepository = workspaceRepository
    }

    func createInvitation(workspaceID: UUID, permission: WorkspacePermission) async throws -> ShareInvitation {
        guard let workspace = try await workspaceRepository.fetchWorkspace(id: workspaceID) else {
            throw ShareRepositoryError.workspaceNotFound
        }

        let invitation = ShareInvitation(
            workspaceID: workspaceID,
            workspaceName: workspace.name,
            inviterUserID: workspace.ownerUserID,
            inviterName: "You",
            permission: permission
        )

        invitations.append(invitation)
        return invitation
    }

    func fetchInvitations(workspaceID: UUID) async throws -> [ShareInvitation] {
        return invitations.filter { $0.workspaceID == workspaceID && $0.status != .revoked }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchPendingInvitations() async throws -> [ShareInvitation] {
        let now = Date()
        return invitations.filter { $0.status == .pending && $0.expiresAt > now }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func acceptInvitation(invitationCode: String) async throws -> Workspace {
        guard let index = invitations.firstIndex(where: { $0.invitationCode == invitationCode }) else {
            throw ShareRepositoryError.invalidInvitationCode
        }

        let invitation = invitations[index]

        guard invitation.status == .pending else {
            throw ShareRepositoryError.invitationAlreadyUsed
        }

        guard invitation.expiresAt > Date() else {
            throw ShareRepositoryError.invitationExpired
        }

        guard let workspace = try await workspaceRepository.fetchWorkspace(id: invitation.workspaceID) else {
            throw ShareRepositoryError.workspaceNotFound
        }

        // Update invitation status
        invitations[index] = ShareInvitation(
            id: invitation.id,
            workspaceID: invitation.workspaceID,
            workspaceName: invitation.workspaceName,
            inviterUserID: invitation.inviterUserID,
            inviterName: invitation.inviterName,
            invitedUserID: "local_user",
            permission: invitation.permission,
            status: .accepted,
            createdAt: invitation.createdAt,
            expiresAt: invitation.expiresAt,
            invitationCode: invitation.invitationCode
        )

        return workspace
    }

    func declineInvitation(invitationID: UUID) async throws {
        guard let index = invitations.firstIndex(where: { $0.id == invitationID }) else {
            throw ShareRepositoryError.invitationNotFound
        }

        let invitation = invitations[index]
        invitations[index] = ShareInvitation(
            id: invitation.id,
            workspaceID: invitation.workspaceID,
            workspaceName: invitation.workspaceName,
            inviterUserID: invitation.inviterUserID,
            inviterName: invitation.inviterName,
            invitedUserID: invitation.invitedUserID,
            permission: invitation.permission,
            status: .declined,
            createdAt: invitation.createdAt,
            expiresAt: invitation.expiresAt,
            invitationCode: invitation.invitationCode
        )
    }

    func revokeInvitation(invitationID: UUID) async throws {
        guard let index = invitations.firstIndex(where: { $0.id == invitationID }) else {
            throw ShareRepositoryError.invitationNotFound
        }

        let invitation = invitations[index]
        invitations[index] = ShareInvitation(
            id: invitation.id,
            workspaceID: invitation.workspaceID,
            workspaceName: invitation.workspaceName,
            inviterUserID: invitation.inviterUserID,
            inviterName: invitation.inviterName,
            invitedUserID: invitation.invitedUserID,
            permission: invitation.permission,
            status: .revoked,
            createdAt: invitation.createdAt,
            expiresAt: invitation.expiresAt,
            invitationCode: invitation.invitationCode
        )
    }

    func validateInvitationCode(_ code: String) async throws -> ShareInvitation? {
        let invitation = invitations.first { $0.invitationCode == code }

        guard let invitation = invitation else {
            return nil
        }

        guard invitation.status == .pending else {
            throw ShareRepositoryError.invitationAlreadyUsed
        }

        guard invitation.expiresAt > Date() else {
            throw ShareRepositoryError.invitationExpired
        }

        return invitation
    }
}
