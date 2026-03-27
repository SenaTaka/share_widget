import Foundation

@MainActor
final class WorkspaceListViewModel: ObservableObject {
    @Published private(set) var workspaces: [Workspace] = []

    private let workspaceRepository: WorkspaceRepository

    init(workspaceRepository: WorkspaceRepository) {
        self.workspaceRepository = workspaceRepository
    }

    func load() {
        workspaces = workspaceRepository.fetchWorkspaces()
    }
}
