import SwiftUI
import PhotosUI

struct NoteEditorView: View {
    @StateObject var viewModel: NoteEditorViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 12) {
            TextField("Note title", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
                .onSubmit(viewModel.updateTitle)
                .padding(.horizontal)

            Picker("Entry type", selection: $viewModel.selectedEntryType) {
                Text("Handwriting").tag(NoteEntryType.handwriting)
                Text("Photo + Message").tag(NoteEntryType.photoMessage)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if viewModel.selectedEntryType == .handwriting {
                PencilCanvasView(drawing: $viewModel.drawing, onChanged: viewModel.drawingDidChange)
            } else {
                photoMessageEditor
            }
        }
        .overlay(alignment: .bottomLeading) {
            SyncStateBadge(state: viewModel.syncState)
                .padding(8)
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.load)
        .onDisappear(perform: viewModel.forceSaveBeforeExit)
        .onChange(of: selectedPhotoItem) { newValue in
            Task {
                await loadSelectedPhoto(item: newValue)
            }
        }
    }

    private var photoMessageEditor: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("写真を選択", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if viewModel.photoReference != nil {
                    Text("写真を選択済み")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                TextField("Author User ID", text: $viewModel.authorUserID)
                    .textFieldStyle(.roundedBorder)

                TextField("一言メッセージ", text: $viewModel.messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)

                Button("写真投稿を保存") {
                    viewModel.savePhotoMessage()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
    }

    private func loadSelectedPhoto(item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return
        }
        viewModel.setSelectedPhotoData(data)
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
