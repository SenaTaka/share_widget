import SwiftUI

@main
struct share_widgetApp: App {
    @State private var routedNoteID: UUID?

    var body: some Scene {
        WindowGroup {
            ContentView(routedNoteID: $routedNoteID)
                .onOpenURL { url in
                    routedNoteID = WidgetBridge.parseNoteID(from: url)
                }
        }
    }
}
