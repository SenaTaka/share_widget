import SwiftUI
import WidgetKit

struct NoteEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetNoteSnapshot
}

struct NoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: Date(), snapshot: .dummy)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        let snapshot = WidgetBridge.loadSnapshot() ?? .dummy
        completion(NoteEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        let snapshot = WidgetBridge.loadSnapshot() ?? .dummy
        let entry = NoteEntry(date: Date(), snapshot: snapshot)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct NoteEntryView: View {
    var entry: NoteTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.snapshot.title)
                .font(.headline)
                .lineLimit(1)
            Text(entry.snapshot.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Spacer()
            Text(entry.snapshot.updatedAt, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(WidgetBridge.makeWidgetURL(noteID: entry.snapshot.noteID))
    }
}

struct share_widgetWidgetExtension: Widget {
    let kind: String = WidgetBridge.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NoteTimelineProvider()) { entry in
            NoteEntryView(entry: entry)
        }
        .configurationDisplayName("Latest Note")
        .description("Shows the latest saved note from the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct share_widgetWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        share_widgetWidgetExtension()
    }
}
