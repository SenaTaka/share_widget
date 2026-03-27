//
//  share_widget_wid.swift
//  share_widget_wid
//
//  Created by Sena Takasawa on 2026/3/27.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let appGroupID = "group.com.sena.share.wid"
    
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
        
        var thumbnailImage: UIImage? = nil
        if let image = UIImage(contentsOfFile: thumbnailURL.path) {
            let maxSize: CGFloat = 150
            let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        noteID = try container.decode(UUID.self, forKey: .noteID)
        title = try container.decode(String.self, forKey: .title)
        thumbnailFileName = try container.decode(String.self, forKey: .thumbnailFileName)
        
        let dateString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        updatedAt = formatter.date(from: dateString) ?? Date()
    }
}

struct NoteEntry: TimelineEntry {
    let date: Date
    let title: String
    let thumbnail: UIImage?
}

struct share_widget_widEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                if let thumbnail = entry.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: iconSize))
                            .foregroundStyle(.secondary)
                        Text(entry.title)
                            .font(titleFont)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if family != .systemSmall {
                    HStack {
                        Text(entry.title)
                            .font(titleFont)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(family == .systemSmall ? 8 : 12)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private var iconSize: CGFloat {
        switch family {
        case .systemSmall: return 32
        case .systemMedium: return 40
        case .systemLarge: return 48
        case .systemExtraLarge: return 56
        default: return 40
        }
    }
    
    private var titleFont: Font {
        switch family {
        case .systemSmall: return .caption
        case .systemMedium: return .subheadline
        case .systemLarge: return .headline
        case .systemExtraLarge: return .title3
        default: return .subheadline
        }
    }
}

struct share_widget_wid: Widget {
    let kind: String = "share_widget_wid"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            share_widget_widEntryView(entry: entry)
        }
        .configurationDisplayName("手書きメモ")
        .description("ピン留めした手書きメモを表示")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

// ロック画面用ウィジェット
struct share_widget_lockscreen: Widget {
    let kind: String = "share_widget_lockscreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("手書きメモ")
        .description("ロック画面にメモを表示")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    if let thumbnail = entry.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
            case .accessoryRectangular:
                HStack(spacing: 8) {
                    if let thumbnail = entry.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .cornerRadius(4)
                    } else {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .frame(width: 40)
                    }
                    VStack(alignment: .leading) {
                        Text(entry.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(entry.date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            case .accessoryInline:
                Label(entry.title, systemImage: "square.and.pencil")
            default:
                EmptyView()
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

#Preview(as: .systemMedium) {
    share_widget_wid()
} timeline: {
    NoteEntry(date: .now, title: "My Note", thumbnail: nil)
}
