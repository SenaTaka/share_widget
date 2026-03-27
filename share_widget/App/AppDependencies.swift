import Foundation
import Combine

@MainActor
final class AppDependencies: ObservableObject {
    let workspaceRepository: WorkspaceRepository

    init(workspaceRepository: WorkspaceRepository = InMemoryWorkspaceRepository()) {
        self.workspaceRepository = workspaceRepository
    }
}
