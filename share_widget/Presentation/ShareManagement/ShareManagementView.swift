import SwiftUI

struct ShareManagementView: View {
    @StateObject private var viewModel: ShareManagementViewModel
    @State private var showingPermissionPicker = false
    @State private var selectedPermission: WorkspacePermission = .readWrite
    @State private var showingCodeSheet = false
    @Environment(\.dismiss) private var dismiss

    init(viewModel: @autoclosure @escaping () -> ShareManagementViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showingPermissionPicker = true
                    } label: {
                        Label("Create Invitation", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Invitations")
                } footer: {
                    Text("Share this workspace by creating an invitation link")
                }

                if !viewModel.invitations.isEmpty {
                    Section("Active Invitations") {
                        ForEach(viewModel.invitations) { invitation in
                            InvitationRow(invitation: invitation) {
                                Task {
                                    await viewModel.revokeInvitation(id: invitation.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Share Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.load()
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
            .confirmationDialog("Select Permission", isPresented: $showingPermissionPicker) {
                Button("Read & Write") {
                    selectedPermission = .readWrite
                    Task {
                        await viewModel.createInvitation(permission: .readWrite)
                        showingCodeSheet = true
                    }
                }
                Button("Read Only") {
                    selectedPermission = .readOnly
                    Task {
                        await viewModel.createInvitation(permission: .readOnly)
                        showingCodeSheet = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose what permission this invitation will grant")
            }
            .sheet(isPresented: $showingCodeSheet) {
                if let code = viewModel.generatedInvitationCode {
                    InvitationCodeSheet(invitationCode: code)
                }
            }
        }
    }
}

struct InvitationRow: View {
    let invitation: ShareInvitation
    let onRevoke: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.permission.rawValue.capitalized)
                        .font(.headline)

                    Text("Created by \(invitation.inviterName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: invitation.status)
            }

            HStack {
                Text("Expires \(invitation.expiresAt, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if invitation.status == .pending {
                    Button("Revoke", role: .destructive) {
                        onRevoke()
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: InvitationStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .pending:
            return .blue
        case .accepted:
            return .green
        case .declined:
            return .gray
        case .expired:
            return .orange
        case .revoked:
            return .red
        }
    }
}

struct InvitationCodeSheet: View {
    let invitationCode: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Invitation Created!")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(spacing: 12) {
                    Text("Share this code:")
                        .font(.headline)

                    Text(invitationCode)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button {
                        UIPasteboard.general.string = invitationCode
                    } label: {
                        Label("Copy Code", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Text("This code will expire in 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Invitation Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let workspaceRepo = InMemoryWorkspaceRepository()
    let shareRepo = InMemoryShareRepository(workspaceRepository: workspaceRepo)
    let workspaceID = UUID()

    return ShareManagementView(
        viewModel: ShareManagementViewModel(
            shareRepository: shareRepo,
            workspaceID: workspaceID
        )
    )
}
