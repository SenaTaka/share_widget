import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let appGroupID = "group.com.example.share_widget"
    
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: Date(), title: "Note Title", thumbnail: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        let entry = loadEntry() ?? NoteEntry(date: Date(), title: "Sample Note", thumbnail: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        let entry = loadEntry() ?? NoteEntry(date: Date(), title: "No Note Pinned", thumbnail: nil)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    private func loadEntry() -> NoteEntry? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        
        let bridgeURL = containerURL.appendingPathComponent("WidgetBridge", isDirectory: true)
        let manifestURL = bridgeURL.appendingPathComponent("pinned_note_manifest.json")
        let thumbnailURL = bridgeURL.appendingPathComponent("pinned_note_thumbnail.png")
        
        guard let manifestData = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONDecoder().decode(WidgetPinnedNoteManifest.self, from: manifestData) else {
            return nil
        }
        
        let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.path)
        
        return NoteEntry(
            date: manifest.updatedAt,
            title: manifest.title,
            thumbnail: thumbnailImage
        )
    }
}

struct WidgetPinnedNoteManifest: Codable {
    let noteID: UUID
    let title: String
    let updatedAt: Date
    let thumbnailFileName: String
}

struct NoteEntry: TimelineEntry {
    let date: Date
    let title: String
    let thumbnail: UIImage?
}

struct share_widgetWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(.headline)
                .lineLimit(1)
            
            if let thumbnail = entry.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
            } else {
                Image(systemName: "square.and.pencil")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Text(entry.date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct share_widgetWidget: Widget {
    let kind: String = "share_widgetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            share_widgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pinned Note")
        .description("Display your pinned handwritten note.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    share_widgetWidget()
} timeline: {
    NoteEntry(date: .now, title: "My Note", thumbnail: nil)
}
