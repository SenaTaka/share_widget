import SwiftUI

struct NoteEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: NoteEditorViewModel

    init(noteID: String) {
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(noteID: noteID))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ノート")
                    .font(.headline)
                Spacer()
                syncStatusView
            }
            .padding()

            PKCanvasViewRepresentable(
                drawing: $viewModel.drawing,
                onDrawingDidChange: viewModel.drawingDidChange
            )
        }
        .onDisappear {
            viewModel.forceSave()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                viewModel.forceSave()
            }
        }
    }

    @ViewBuilder
    private var syncStatusView: some View {
        switch viewModel.syncState {
        case .saving:
            Label("保存中", systemImage: "arrow.triangle.2.circlepath")
                .foregroundStyle(.orange)
        case .upToDate:
            Label("最新", systemImage: "checkmark.circle")
                .foregroundStyle(.green)
        case .error:
            Label("エラー", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    NoteEditorView(noteID: "preview")
}
