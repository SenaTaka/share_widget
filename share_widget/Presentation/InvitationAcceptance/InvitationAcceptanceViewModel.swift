import Foundation

@MainActor
final class InvitationAcceptanceViewModel: ObservableObject {
    @Published var invitationCode = ""
    @Published private(set) var invitation: ShareInvitation?
    @Published var errorMessage: String?
    @Published private(set) var isValidating = false
    @Published private(set) var acceptedWorkspace: Workspace?

    private let shareRepository: ShareRepository

    init(shareRepository: ShareRepository) {
        self.shareRepository = shareRepository
    }

    func validateCode() async {
        guard !invitationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter an invitation code"
            return
        }

        isValidating = true
        do {
            invitation = try await shareRepository.validateInvitationCode(invitationCode)
            if invitation == nil {
                errorMessage = "Invalid invitation code"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isValidating = false
    }

    func acceptInvitation() async {
        guard invitation != nil else {
            errorMessage = "No valid invitation to accept"
            return
        }

        do {
            acceptedWorkspace = try await shareRepository.acceptInvitation(invitationCode: invitationCode)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        invitationCode = ""
        invitation = nil
        errorMessage = nil
        acceptedWorkspace = nil
        isValidating = false
    }
}
