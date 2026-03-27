import Foundation

actor InMemoryWorkspaceRepository: WorkspaceRepository {
    private var workspaces: [Workspace] = []

    init() {
        // Initialize with sample data
        let owner = WorkspaceMember(
            userID: "local_user",
            displayName: "You",
            permission: .owner
        )

        workspaces = [
            Workspace(
                name: "Personal",
                ownerUserID: "local_user",
                isShared: false,
                members: [owner]
            ),
            Workspace(
                name: "Team Wiki",
                ownerUserID: "local_user",
                isShared: true,
                members: [
                    owner,
                    WorkspaceMember(
                        userID: "user_2",
                        displayName: "Alice",
                        permission: .readWrite
                    )
                ]
            ),
            Workspace(
                name: "Ideas",
                ownerUserID: "local_user",
                isShared: false,
                members: [owner]
            )
        ]
    }

    func fetchWorkspaces() async throws -> [Workspace] {
        return workspaces.filter { !$0.isArchived }.sorted { $0.updatedAt > $1.updatedAt }
    }

    func fetchWorkspace(id: UUID) async throws -> Workspace? {
        return workspaces.first { $0.id == id }
    }

    func createWorkspace(name: String) async throws -> Workspace {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkspaceRepositoryError.invalidWorkspaceName
        }

        let owner = WorkspaceMember(
            userID: "local_user",
            displayName: "You",
            permission: .owner
        )

        let workspace = Workspace(
            name: name,
            ownerUserID: "local_user",
            isShared: false,
            members: [owner]
        )

        workspaces.append(workspace)
        return workspace
    }

    func updateWorkspace(id: UUID, name: String) async throws -> Workspace {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkspaceRepositoryError.invalidWorkspaceName
        }

        guard let index = workspaces.firstIndex(where: { $0.id == id }) else {
            throw WorkspaceRepositoryError.workspaceNotFound
        }

        workspaces[index].name = name
        workspaces[index].updatedAt = Date()
        return workspaces[index]
    }

    func archiveWorkspace(id: UUID) async throws {
        guard let index = workspaces.firstIndex(where: { $0.id == id }) else {
            throw WorkspaceRepositoryError.workspaceNotFound
        }

        workspaces[index].isArchived = true
        workspaces[index].updatedAt = Date()
    }

    func unarchiveWorkspace(id: UUID) async throws {
        guard let index = workspaces.firstIndex(where: { $0.id == id }) else {
            throw WorkspaceRepositoryError.workspaceNotFound
        }

        workspaces[index].isArchived = false
        workspaces[index].updatedAt = Date()
    }

    func deleteWorkspace(id: UUID) async throws {
        guard let index = workspaces.firstIndex(where: { $0.id == id }) else {
            throw WorkspaceRepositoryError.workspaceNotFound
        }

        workspaces.remove(at: index)
    }
}

