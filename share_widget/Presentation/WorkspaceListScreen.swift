import SwiftUI

struct WorkspaceListScreen: View {
    @StateObject private var viewModel: WorkspaceListViewModel

    init(viewModel: @autoclosure @escaping () -> WorkspaceListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            List(viewModel.workspaces) { workspace in
                HStack {
                    Text(workspace.name)
                    Spacer()
                    Text(workspace.syncState.rawValue)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Workspaces")
        }
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    WorkspaceListScreen(viewModel: WorkspaceListViewModel(workspaceRepository: InMemoryWorkspaceRepository()))
}
