import Foundation
import PencilKit
import UIKit
import WidgetKit

struct WidgetPinnedNoteManifest: Codable {
    let noteID: UUID
    let title: String
    let updatedAt: Date
    let thumbnailFileName: String
}

protocol WidgetBridge {
    func syncPinnedNote(_ note: Note?) async
}

actor AppGroupWidgetBridge: WidgetBridge {
    private let appGroupID: String
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    init(
        appGroupID: String = "group.com.sena.share.wid",
        fileManager: FileManager = .default,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.appGroupID = appGroupID
        self.fileManager = fileManager
        self.encoder = encoder
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func syncPinnedNote(_ note: Note?) async {
        guard let containerURL = resolveContainerURL() else { return }

        do {
            try fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return
        }

        let manifestURL = containerURL.appendingPathComponent("pinned_note_manifest.json")
        let thumbnailURL = containerURL.appendingPathComponent("pinned_note_thumbnail.png")

        guard let note else {
            try? fileManager.removeItem(at: manifestURL)
            try? fileManager.removeItem(at: thumbnailURL)
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let thumbnailData = renderThumbnailData(from: note.drawingData)
        do {
            try thumbnailData.write(to: thumbnailURL, options: .atomic)

            let manifest = WidgetPinnedNoteManifest(
                noteID: note.id,
                title: note.title,
                updatedAt: note.updatedAt,
                thumbnailFileName: thumbnailURL.lastPathComponent
            )
            let encodedManifest = try encoder.encode(manifest)
            try encodedManifest.write(to: manifestURL, options: .atomic)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Widget cache write failures are intentionally ignored.
        }
    }

    private func resolveContainerURL() -> URL? {
        if let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return appGroupURL.appendingPathComponent("WidgetBridge", isDirectory: true)
        }

        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("WidgetBridgeFallback", isDirectory: true)
    }

    private func renderThumbnailData(from drawingData: Data) -> Data {
        guard let drawing = try? PKDrawing(data: drawingData), !drawing.bounds.isNull, !drawing.bounds.isEmpty else {
            return UIImage(systemName: "square.and.pencil")?.pngData() ?? Data()
        }

        let targetSize = CGSize(width: 320, height: 200)
        let image = drawing.image(from: drawing.bounds, scale: 2)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.pngData { context in
            UIColor.systemBackground.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            let aspectRatio = min(
                targetSize.width / image.size.width,
                targetSize.height / image.size.height
            )
            let drawSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            let origin = CGPoint(
                x: (targetSize.width - drawSize.width) / 2,
                y: (targetSize.height - drawSize.height) / 2
            )
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }
}

struct WidgetBridgeNoop: WidgetBridge {
    func syncPinnedNote(_ note: Note?) async {}
}
