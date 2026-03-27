import SwiftUI

struct NoteEditorView: View {
    @StateObject var viewModel: NoteEditorViewModel

    var body: some View {
        VStack(spacing: 12) {
            TextField("Note title", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
                .onSubmit(viewModel.updateTitle)
                .padding(.horizontal)

            PencilCanvasView(drawing: $viewModel.drawing, onChanged: viewModel.drawingDidChange)
                .overlay(alignment: .bottomLeading) {
                    SyncStateBadge(state: viewModel.syncState)
                        .padding(8)
                }
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.load)
        .onDisappear(perform: viewModel.forceSaveBeforeExit)
    }
}

private struct SyncStateBadge: View {
    let state: SyncState

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private var label: String {
        switch state {
        case .idle:
            return "Idle"
        case .saving:
            return "Saving..."
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            return "Synced \(date.formatted(date: .omitted, time: .shortened))"
        case .conflict:
            return "Conflict"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}
