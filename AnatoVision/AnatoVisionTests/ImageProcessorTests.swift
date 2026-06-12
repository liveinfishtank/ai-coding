import XCTest
import UIKit
@testable import AnatoVision

final class ImageProcessorTests: XCTestCase {
    func testNormalizedJPEGDataDownsizesLargeImage() throws {
        let image = makeImage(size: CGSize(width: 400, height: 200))

        let data = try ImageProcessor.normalizedJPEGData(from: image, maxLongEdge: 100, compressionQuality: 0.9)
        let output = try XCTUnwrap(UIImage(data: data))

        XCTAssertLessThanOrEqual(max(output.size.width, output.size.height), 101)
        XCTAssertGreaterThan(data.count, 0)
    }

    func testNormalizedJPEGDataKeepsSmallImageDimensions() throws {
        let image = makeImage(size: CGSize(width: 80, height: 60))

        let data = try ImageProcessor.normalizedJPEGData(from: image, maxLongEdge: 100, compressionQuality: 0.9)
        let output = try XCTUnwrap(UIImage(data: data))

        XCTAssertEqual(output.size.width, 80, accuracy: 1)
        XCTAssertEqual(output.size.height, 60, accuracy: 1)
    }

    private func makeImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.red.setFill()
            context.fill(CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5))
        }
    }
}
