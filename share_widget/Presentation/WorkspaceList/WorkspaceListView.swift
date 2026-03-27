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
                    NoteTimelineCard(note: note)
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
        .navigationTitle("交換日記")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.createNote) {
                    Label("新規投稿", systemImage: "square.and.pencil")
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

private struct NoteTimelineCard: View {
    let note: Note

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: note.entryType == .photoMessage ? "photo" : "pencil.and.scribble")
                .font(.title2)
                .foregroundStyle(note.entryType == .photoMessage ? .purple : .blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.headline)

                if note.entryType == .photoMessage {
                    Text(note.messageText?.isEmpty == false ? (note.messageText ?? "") : "(メッセージなし)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    if let authorUserID = note.authorUserID, !authorUserID.isEmpty {
                        Text("by \(authorUserID)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("手書き投稿")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

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
    }
}
