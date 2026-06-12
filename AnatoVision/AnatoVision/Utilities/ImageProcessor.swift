import UIKit

enum ImageProcessor {
    static func normalizedJPEGData(from image: UIImage, maxLongEdge: CGFloat = 1600, compressionQuality: CGFloat = 0.82) throws -> Data {
        let resized = resizedImage(image, maxLongEdge: maxLongEdge)
        guard let data = resized.jpegData(compressionQuality: compressionQuality) else {
            throw AnatomyReviewError.invalidImage
        }
        return data
    }

    private static func resizedImage(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxLongEdge else { return image }

        let scale = maxLongEdge / longest
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
