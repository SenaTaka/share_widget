import Foundation
import Combine

@MainActor
final class ShareManagementViewModel: ObservableObject {
    @Published private(set) var invitations: [ShareInvitation] = []
    @Published var errorMessage: String?
    @Published var generatedInvitationCode: String?

    private let shareRepository: ShareRepository
    private let workspaceID: UUID

    init(shareRepository: ShareRepository, workspaceID: UUID) {
        self.shareRepository = shareRepository
        self.workspaceID = workspaceID
    }

    func load() async {
        do {
            invitations = try await shareRepository.fetchInvitations(workspaceID: workspaceID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createInvitation(permission: WorkspacePermission) async {
        do {
            let invitation = try await shareRepository.createInvitation(workspaceID: workspaceID, permission: permission)
            generatedInvitationCode = invitation.invitationCode
            invitations = try await shareRepository.fetchInvitations(workspaceID: workspaceID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func revokeInvitation(id: UUID) async {
        do {
            try await shareRepository.revokeInvitation(invitationID: id)
            invitations = try await shareRepository.fetchInvitations(workspaceID: workspaceID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
