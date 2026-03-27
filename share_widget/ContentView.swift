import SwiftUI

struct Note: Identifiable, Equatable {
    let id: UUID
    let title: String
    let body: String
}

struct ContentView: View {
    @Binding var routedNoteID: UUID?

    @State private var notes: [Note] = [
        Note(id: WidgetNoteSnapshot.dummy.noteID, title: WidgetNoteSnapshot.dummy.title, body: WidgetNoteSnapshot.dummy.body)
    ]
    @State private var titleInput = ""
    @State private var bodyInput = ""

    private var selectedNote: Note? {
        guard let routedNoteID else { return nil }
        return notes.first(where: { $0.id == routedNoteID })
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("New Note") {
                    VStack(spacing: 12) {
                        TextField("Title", text: $titleInput)
                            .textFieldStyle(.roundedBorder)
                        TextField("Body", text: $bodyInput, axis: .vertical)
                            .lineLimit(3...5)
                            .textFieldStyle(.roundedBorder)
                        Button("Save & Reload Widget") {
                            saveNote()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.top, 4)
                }

                GroupBox("Notes") {
                    List(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minHeight: 180)
                }

                if let selectedNote {
                    GroupBox("Opened from Widget") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(selectedNote.title)
                                .font(.headline)
                            Text(selectedNote.body)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
            .navigationTitle("share_widget")
        }
    }

    private func saveNote() {
        let newNote = Note(
            id: UUID(),
            title: titleInput.isEmpty ? "Untitled" : titleInput,
            body: bodyInput.isEmpty ? "(empty)" : bodyInput
        )

        notes.insert(newNote, at: 0)
        routedNoteID = newNote.id

        let snapshot = WidgetNoteSnapshot(
            noteID: newNote.id,
            title: newNote.title,
            body: newNote.body,
            updatedAt: Date()
        )
        WidgetBridge.saveSnapshotAndReload(snapshot)

        titleInput = ""
        bodyInput = ""
    }
}

#Preview {
    ContentView(routedNoteID: .constant(nil))
}
