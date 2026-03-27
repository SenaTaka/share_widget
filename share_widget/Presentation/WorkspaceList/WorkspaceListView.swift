import SwiftUI

struct WorkspaceListView: View {
    @StateObject var viewModel: WorkspaceListViewModel

    var body: some View {
        List {
            ForEach(viewModel.notes) { note in
                NavigationLink {
                    NoteEditorView(viewModel: NoteEditorViewModel(noteID: note.id, repository: viewModel.repository))
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.updatedAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: viewModel.deleteNotes)
        }
        .navigationTitle("Shared Notes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.createNote) {
                    Label("New Note", systemImage: "plus")
                }
            }
        }
        .task { viewModel.onAppear() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}
