import SwiftUI

struct WorkspaceListView: View {
    @StateObject var viewModel: NoteListViewModel

    var body: some View {
        List {
            ForEach(viewModel.notes) { note in
                NavigationLink {
                    NoteEditorView(
                        viewModel: NoteEditorViewModel(
                            noteID: note.id,
                            repository: viewModel.repository,
                            widgetBridge: viewModel.widgetBridge
                        )
                    )
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.richtext")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.updatedAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if note.isPinnedToWidget {
                            Label("Widget", systemImage: "rectangle.on.rectangle")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.yellow.opacity(0.2))
                                .foregroundStyle(.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        viewModel.pinToWidget(noteID: note.id)
                    } label: {
                        Label("ウィジェットに表示", systemImage: "rectangle.on.rectangle")
                    }
                    .tint(.orange)
                }
            }
            .onDelete(perform: viewModel.deleteNotes)
        }
        .navigationTitle("メモ一覧")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.createNote) {
                    Label("新規メモ", systemImage: "square.and.pencil")
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
