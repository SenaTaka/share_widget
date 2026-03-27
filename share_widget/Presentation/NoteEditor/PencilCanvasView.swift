import PencilKit
import SwiftUI

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var onChanged: (PKDrawing) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, onChanged: onChanged)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.drawing = drawing
        canvas.alwaysBounceVertical = true
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .white
        canvas.overrideUserInterfaceStyle = .light
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        let onChanged: (PKDrawing) -> Void

        init(drawing: Binding<PKDrawing>, onChanged: @escaping (PKDrawing) -> Void) {
            _drawing = drawing
            self.onChanged = onChanged
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
            onChanged(canvasView.drawing)
        }
    }
}
