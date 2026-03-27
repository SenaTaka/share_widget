struct AppCompositionRoot {
    let workspaceRepository: WorkspaceRepository
    let noteRepository: NoteRepository

    static func makeDefault() -> AppCompositionRoot {
        AppCompositionRoot(
            workspaceRepository: InMemoryWorkspaceRepository(),
            noteRepository: InMemoryNoteRepository()
        )
    }

    func makeWorkspaceListViewModel() -> WorkspaceListViewModel {
        WorkspaceListViewModel(workspaceRepository: workspaceRepository)
    }
}
