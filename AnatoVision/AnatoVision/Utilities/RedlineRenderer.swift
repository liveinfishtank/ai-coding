import UIKit

enum RedlineRenderer {
    static func renderRedline(on image: UIImage) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)

        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))

            let cgContext = context.cgContext
            cgContext.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.82).cgColor)
            cgContext.setLineWidth(max(image.size.width, image.size.height) * 0.012)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            let w = image.size.width
            let h = image.size.height

            drawLine(in: cgContext, points: [
                CGPoint(x: w * 0.50, y: h * 0.16),
                CGPoint(x: w * 0.48, y: h * 0.30),
                CGPoint(x: w * 0.52, y: h * 0.48),
                CGPoint(x: w * 0.49, y: h * 0.68)
            ])
            drawLine(in: cgContext, points: [
                CGPoint(x: w * 0.31, y: h * 0.31),
                CGPoint(x: w * 0.49, y: h * 0.30),
                CGPoint(x: w * 0.68, y: h * 0.34)
            ])
            drawLine(in: cgContext, points: [
                CGPoint(x: w * 0.37, y: h * 0.50),
                CGPoint(x: w * 0.52, y: h * 0.49),
                CGPoint(x: w * 0.65, y: h * 0.53)
            ])
            drawLine(in: cgContext, points: [
                CGPoint(x: w * 0.41, y: h * 0.68),
                CGPoint(x: w * 0.35, y: h * 0.86)
            ])
            drawLine(in: cgContext, points: [
                CGPoint(x: w * 0.56, y: h * 0.68),
                CGPoint(x: w * 0.65, y: h * 0.87)
            ])

            cgContext.setFillColor(UIColor.systemRed.withAlphaComponent(0.95).cgColor)
            for point in [
                CGPoint(x: w * 0.50, y: h * 0.16),
                CGPoint(x: w * 0.49, y: h * 0.30),
                CGPoint(x: w * 0.52, y: h * 0.49),
                CGPoint(x: w * 0.49, y: h * 0.68)
            ] {
                let radius = max(w, h) * 0.018
                cgContext.fillEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
            }
        }
    }

    private static func drawLine(in context: CGContext, points: [CGPoint]) {
        guard let first = points.first else { return }
        context.beginPath()
        context.move(to: first)
        for point in points.dropFirst() {
            context.addLine(to: point)
        }
        context.strokePath()
    }
}
