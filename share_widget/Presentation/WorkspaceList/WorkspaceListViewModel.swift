import Foundation

@MainActor
final class WorkspaceListViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var errorMessage: String?

    let repository: NoteRepository

    init(repository: NoteRepository) {
        self.repository = repository
    }

    func onAppear() {
        Task { await refresh() }
    }

    func refresh() async {
        do {
            notes = try await repository.fetchNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createNote() {
        Task {
            do {
                _ = try await repository.createNote(title: "New Note")
                notes = try await repository.fetchNotes()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func pinToWidget(noteID: UUID) {
        Task {
            do {
                _ = try await repository.pinNoteToWidget(noteID: noteID)
                notes = try await repository.fetchNotes()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deleteNotes(at offsets: IndexSet) {
        let targets = offsets.compactMap { index in notes.indices.contains(index) ? notes[index] : nil }
        Task {
            do {
                for target in targets {
                    try await repository.delete(noteID: target.id)
                }
                notes = try await repository.fetchNotes()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
