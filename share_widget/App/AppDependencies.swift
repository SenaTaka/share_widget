import Foundation

@MainActor
final class AppDependencies: ObservableObject {
    let noteRepository: NoteRepository

    init(noteRepository: NoteRepository = InMemoryNoteRepository()) {
        self.noteRepository = noteRepository
    }
}
