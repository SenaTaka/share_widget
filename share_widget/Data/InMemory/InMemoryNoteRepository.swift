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

    func createPhotoMessageEntry(
        title: String,
        photoReference: String,
        messageText: String,
        authorUserID: String
    ) async throws -> Note {
        let note = Note(
            title: title,
            entryType: .photoMessage,
            photoReference: photoReference,
            messageText: messageText,
            authorUserID: authorUserID
        )
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

    func updateMessage(noteID: UUID, messageText: String) async throws -> Note {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }
        notes[index].entryType = .photoMessage
        notes[index].messageText = messageText
        notes[index].updatedAt = Date()
        return notes[index]
    }


    func updatePhotoMessageEntry(
        noteID: UUID,
        title: String,
        photoReference: String,
        messageText: String,
        authorUserID: String
    ) async throws -> Note {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }

        notes[index].title = title
        notes[index].entryType = .photoMessage
        notes[index].photoReference = photoReference
        notes[index].messageText = messageText
        notes[index].authorUserID = authorUserID
        notes[index].updatedAt = Date()
        return notes[index]
    }

    func saveDrawing(noteID: UUID, drawingData: Data) async throws -> Note {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }
        notes[index].drawingData = drawingData
        notes[index].entryType = .handwriting
        notes[index].updatedAt = Date()
        return notes[index]
    }

    func pinNoteToWidget(noteID: UUID) async throws -> Note {
        guard notes.contains(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }

        for index in notes.indices {
            notes[index].isPinnedToWidget = notes[index].id == noteID
        }

        guard let pinnedIndex = notes.firstIndex(where: { $0.id == noteID }) else {
            throw RepositoryError.noteNotFound
        }
        notes[pinnedIndex].updatedAt = Date()
        return notes[pinnedIndex]
    }

    func delete(noteID: UUID) async throws {
        notes.removeAll(where: { $0.id == noteID })
    }

    func fetchNote(noteID: UUID) async throws -> Note? {
        notes.first(where: { $0.id == noteID })
    }

    func fetchPinnedNote() async throws -> Note? {
        notes.first(where: \.isPinnedToWidget)
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
