import SwiftUI

@main
struct share_widgetApp: App {
    private let compositionRoot = AppCompositionRoot.makeDefault()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModelFactory: compositionRoot.makeWorkspaceListViewModel)
        }
    }
}
