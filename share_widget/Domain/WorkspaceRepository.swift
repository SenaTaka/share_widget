import Foundation

protocol WorkspaceRepository {
    func fetchWorkspaces() async throws -> [Workspace]
    func fetchWorkspace(id: UUID) async throws -> Workspace?
    func createWorkspace(name: String) async throws -> Workspace
    func updateWorkspace(id: UUID, name: String) async throws -> Workspace
    func archiveWorkspace(id: UUID) async throws
    func unarchiveWorkspace(id: UUID) async throws
    func deleteWorkspace(id: UUID) async throws
}

enum WorkspaceRepositoryError: Error, LocalizedError {
    case workspaceNotFound
    case invalidWorkspaceName
    case archiveError
    case deleteError

    var errorDescription: String? {
        switch self {
        case .workspaceNotFound:
            return "Workspace not found"
        case .invalidWorkspaceName:
            return "Invalid workspace name"
        case .archiveError:
            return "Failed to archive workspace"
        case .deleteError:
            return "Failed to delete workspace"
        }
    }
}
