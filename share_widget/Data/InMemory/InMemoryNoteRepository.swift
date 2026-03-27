import Foundation

actor InMemoryNoteRepository: NoteRepository {
    private var notes: [Note]

    init(seed: [Note] = []) {
        if seed.isEmpty {
            notes = [
                Note(title: "Welcome Note"),
                Note(title: "Team Board")
            ]
        } else {
            notes = seed
        }
    }

    func fetchNotes() async throws -> [Note] {
        notes.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    func createNote(title: String) async throws -> Note {
        let note = Note(title: title)
        notes.append(note)
        return note
    }

    func updateTitle(noteID: UUID, title: String) async throws -> Note {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }
        notes[index].title = title
        notes[index].updatedAt = Date()
        return notes[index]
    }

    func saveDrawing(noteID: UUID, drawingData: Data) async throws -> Note {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }
        notes[index].drawingData = drawingData
        notes[index].updatedAt = Date()
        return notes[index]
    }

    func delete(noteID: UUID) async throws {
        notes.removeAll(where: { $0.id == noteID })
    }

    func fetchNote(noteID: UUID) async throws -> Note? {
        notes.first(where: { $0.id == noteID })
    }
}

enum RepositoryError: LocalizedError {
    case noteNotFound

    var errorDescription: String? {
        switch self {
        case .noteNotFound:
            return "The requested note could not be found."
        }
    }
}
