import Foundation

@MainActor
final class WorkspaceListViewModel: ObservableObject {
    @Published private(set) var workspaces: [Workspace] = []
    @Published var errorMessage: String?
    @Published var isCreatingWorkspace = false
    @Published var workspaceToEdit: Workspace?

    private let workspaceRepository: WorkspaceRepository

    init(workspaceRepository: WorkspaceRepository) {
        self.workspaceRepository = workspaceRepository
    }

    func load() async {
        do {
            workspaces = try await workspaceRepository.fetchWorkspaces()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createWorkspace(name: String) async {
        do {
            _ = try await workspaceRepository.createWorkspace(name: name)
            workspaces = try await workspaceRepository.fetchWorkspaces()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateWorkspace(id: UUID, name: String) async {
        do {
            _ = try await workspaceRepository.updateWorkspace(id: id, name: name)
            workspaces = try await workspaceRepository.fetchWorkspaces()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func archiveWorkspace(id: UUID) async {
        do {
            try await workspaceRepository.archiveWorkspace(id: id)
            workspaces = try await workspaceRepository.fetchWorkspaces()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteWorkspace(id: UUID) async {
        do {
            try await workspaceRepository.deleteWorkspace(id: id)
            workspaces = try await workspaceRepository.fetchWorkspaces()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

