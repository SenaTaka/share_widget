import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

public enum WidgetBridge {
    public static let appGroupID = "group.com.example.share_widget"
    public static let snapshotKey = "widget.note.snapshot"
    public static let widgetKind = "share_widgetWidget"
    public static let urlScheme = "sharewidget"

    public static func loadSnapshot() -> WidgetNoteSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: snapshotKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetNoteSnapshot.self, from: data)
    }

    public static func saveSnapshot(_ snapshot: WidgetNoteSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(snapshot) else {
            return
        }
        defaults.set(data, forKey: snapshotKey)
    }

    public static func saveSnapshotAndReload(_ snapshot: WidgetNoteSnapshot) {
        saveSnapshot(snapshot)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        #endif
    }

    public static func makeWidgetURL(noteID: UUID) -> URL {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = "note"
        components.queryItems = [URLQueryItem(name: "noteID", value: noteID.uuidString)]
        if let url = components.url {
            return url
        }
        return URL(fileURLWithPath: "/")
    }

    public static func parseNoteID(from url: URL) -> UUID? {
        guard url.scheme == urlScheme,
              url.host == "note",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let noteID = components.queryItems?.first(where: { $0.name == "noteID" })?.value else {
            return nil
        }
        return UUID(uuidString: noteID)
    }
}
