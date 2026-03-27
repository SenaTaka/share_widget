import SwiftUI
import PencilKit

struct ConflictResolutionView: View {
    @StateObject private var viewModel: ConflictResolutionViewModel
    let onResolve: (ConflictResolutionAction) -> Void
    @Environment(\.dismiss) private var dismiss

    init(
        conflict: ConflictResolution,
        onResolve: @escaping (ConflictResolutionAction) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: ConflictResolutionViewModel(conflict: conflict))
        self.onResolve = onResolve
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Warning Header
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)

                    Text("Conflict Detected")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("The note \"\(viewModel.conflict.noteTitle)\" was modified by someone else while you were editing. Choose which version to keep.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.orange.opacity(0.1))

                ScrollView {
                    VStack(spacing: 24) {
                        // Local Version
                        VersionCard(
                            title: "Your Version",
                            version: viewModel.conflict.localVersion,
                            isSelected: viewModel.selectedAction == .keepLocal,
                            action: {
                                viewModel.selectAction(.keepLocal)
                            }
                        )

                        // Remote Version
                        VersionCard(
                            title: "Remote Version",
                            version: viewModel.conflict.remoteVersion,
                            isSelected: viewModel.selectedAction == .keepRemote,
                            action: {
                                viewModel.selectAction(.keepRemote)
                            }
                        )
                    }
                    .padding()
                }

                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        if let action = viewModel.selectedAction {
                            onResolve(action)
                            dismiss()
                        }
                    } label: {
                        Text("Resolve Conflict")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.selectedAction == nil)

                    Button("Cancel", role: .cancel) {
                        onResolve(.cancel)
                        dismiss()
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            }
            .navigationTitle("Resolve Conflict")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct VersionCard: View {
    let title: String
    let version: ConflictVersion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.gray)
                            .font(.title3)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    InfoLabel(
                        icon: "person",
                        text: "Modified by \(version.updatedByName)"
                    )

                    InfoLabel(
                        icon: "clock",
                        text: "Updated \(version.updatedAt.formatted(date: .abbreviated, time: .shortened))"
                    )

                    InfoLabel(
                        icon: "doc.badge.gearshape",
                        text: "Revision \(version.revision)"
                    )
                }

                // Drawing Preview
                if let drawing = try? PKDrawing(data: version.drawingData) {
                    DrawingPreview(drawing: drawing)
                        .frame(height: 150)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(isSelected ? Color.green.opacity(0.1) : Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct InfoLabel: View {
    let icon: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)
        }
    }
}

struct DrawingPreview: View {
    let drawing: PKDrawing

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: drawing.image(from: drawing.bounds, scale: 1.0))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
    }
}

#Preview {
    let conflict = ConflictResolution(
        noteID: UUID(),
        noteTitle: "Test Note",
        localVersion: ConflictVersion(
            revision: 5,
            updatedAt: Date(),
            updatedByUserID: "local_user",
            updatedByName: "You",
            drawingData: Data()
        ),
        remoteVersion: ConflictVersion(
            revision: 6,
            updatedAt: Date().addingTimeInterval(-120),
            updatedByUserID: "remote_user",
            updatedByName: "Alice",
            drawingData: Data()
        )
    )

    return ConflictResolutionView(conflict: conflict) { action in
        print("Resolved with action: \(action)")
    }
}
