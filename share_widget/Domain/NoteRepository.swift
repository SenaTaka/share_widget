protocol NoteRepository {
    func fetchNotes(in workspaceID: Workspace.ID) -> [Note]
}
