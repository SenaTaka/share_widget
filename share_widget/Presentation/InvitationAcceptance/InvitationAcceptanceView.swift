import SwiftUI

struct InvitationAcceptanceView: View {
    @StateObject private var viewModel: InvitationAcceptanceViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: @autoclosure @escaping () -> InvitationAcceptanceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if viewModel.acceptedWorkspace != nil {
                    successView
                } else if let invitation = viewModel.invitation {
                    invitationDetailsView(invitation: invitation)
                } else {
                    codeInputView
                }
            }
            .padding()
            .navigationTitle("Join Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    private var codeInputView: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.open")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Enter Invitation Code")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Invitation Code")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Enter code", text: $viewModel.invitationCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))

                Text("Paste the invitation code you received")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                Task {
                    await viewModel.validateCode()
                }
            } label: {
                if viewModel.isValidating {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Validate Code")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.invitationCode.isEmpty || viewModel.isValidating)

            Spacer()
        }
    }

    private func invitationDetailsView(invitation: ShareInvitation) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Join \"\(invitation.workspaceName)\"?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Invited by \(invitation.inviterName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                InfoRow(
                    icon: "person.badge.key",
                    title: "Permission",
                    value: invitation.permission.rawValue.capitalized
                )

                InfoRow(
                    icon: "clock",
                    title: "Expires",
                    value: invitation.expiresAt.formatted(date: .abbreviated, time: .shortened)
                )
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.acceptInvitation()
                    }
                } label: {
                    Text("Accept Invitation")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button("Decline", role: .cancel) {
                    viewModel.reset()
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
    }

    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Successfully Joined!")
                    .font(.title2)
                    .fontWeight(.bold)

                if let workspace = viewModel.acceptedWorkspace {
                    Text("You're now a member of \"\(workspace.name)\"")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label {
                Text(title)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
            }

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let workspaceRepo = InMemoryWorkspaceRepository()
    let shareRepo = InMemoryShareRepository(workspaceRepository: workspaceRepo)

    return InvitationAcceptanceView(
        viewModel: InvitationAcceptanceViewModel(shareRepository: shareRepo)
    )
}
