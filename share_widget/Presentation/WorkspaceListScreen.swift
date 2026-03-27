import SwiftUI

struct WorkspaceListScreen: View {
    @StateObject private var viewModel: WorkspaceListViewModel
    private let noteRepository: NoteRepository
    private let widgetBridge: WidgetBridge
    @State private var showingCreateDialog = false
    @State private var newWorkspaceName = ""
    @State private var showingEditDialog = false
    @State private var editingWorkspace: Workspace?
    @State private var editedName = ""

    init(
        viewModel: @autoclosure @escaping () -> WorkspaceListViewModel,
        noteRepository: NoteRepository,
        widgetBridge: WidgetBridge
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.noteRepository = noteRepository
        self.widgetBridge = widgetBridge
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.workspaces) { workspace in
                    NavigationLink {
                        WorkspaceListView(
                            viewModel: NoteListViewModel(
                                repository: noteRepository,
                                widgetBridge: widgetBridge
                            )
                        )
                    } label: {
                        WorkspaceRow(workspace: workspace)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteWorkspace(id: workspace.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            Task {
                                await viewModel.archiveWorkspace(id: workspace.id)
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingWorkspace = workspace
                            editedName = workspace.name
                            showingEditDialog = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Workspaces")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateDialog = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Create Workspace", isPresented: $showingCreateDialog) {
                TextField("Workspace Name", text: $newWorkspaceName)
                Button("Cancel", role: .cancel) {
                    newWorkspaceName = ""
                }
                Button("Create") {
                    Task {
                        await viewModel.createWorkspace(name: newWorkspaceName)
                        newWorkspaceName = ""
                    }
                }
            } message: {
                Text("Enter a name for your new workspace")
            }
            .alert("Edit Workspace", isPresented: $showingEditDialog) {
                TextField("Workspace Name", text: $editedName)
                Button("Cancel", role: .cancel) {
                    editingWorkspace = nil
                    editedName = ""
                }
                Button("Save") {
                    if let workspace = editingWorkspace {
                        Task {
                            await viewModel.updateWorkspace(id: workspace.id, name: editedName)
                            editingWorkspace = nil
                            editedName = ""
                        }
                    }
                }
            } message: {
                Text("Enter a new name for the workspace")
            }
        }
    }
}

struct WorkspaceRow: View {
    let workspace: Workspace

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workspace.name)
                    .font(.headline)

                Spacer()

                if workspace.isShared {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            HStack {
                Text("Updated \(workspace.updatedAt, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if workspace.members.count > 1 {
                    Text("\(workspace.members.count) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkspaceListScreen(
        viewModel: WorkspaceListViewModel(workspaceRepository: InMemoryWorkspaceRepository()),
        noteRepository: InMemoryNoteRepository(),
        widgetBridge: WidgetBridgeNoop()
    )
}
