import Foundation

struct InMemoryNoteRepository: NoteRepository {
    private let notes: [Note] = {
        let personal = UUID()
        let teamWiki = UUID()

        return [
            Note(id: UUID(), workspaceID: personal, title: "買い物メモ", body: "牛乳、卵、コーヒー", updatedAt: .now),
            Note(id: UUID(), workspaceID: teamWiki, title: "Weekly Meeting", body: "進捗と課題", updatedAt: .now),
        ]
    }()

    func fetchNotes(in workspaceID: Workspace.ID) -> [Note] {
        notes.filter { $0.workspaceID == workspaceID }
    }
}
