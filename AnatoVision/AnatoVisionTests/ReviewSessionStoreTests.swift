import XCTest
@testable import AnatoVision

final class ReviewSessionStoreTests: XCTestCase {
    private var temporaryDirectory: URL!

    override func setUpWithError() throws {
        temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDownWithError() throws {
        if let temporaryDirectory, FileManager.default.fileExists(atPath: temporaryDirectory.path) {
            try FileManager.default.removeItem(at: temporaryDirectory)
        }
    }

    func testSaveLoadAndDeleteSession() throws {
        let store = ReviewSessionStore(rootDirectory: temporaryDirectory)
        let original = try XCTUnwrap("original".data(using: .utf8))
        let redline = try XCTUnwrap("redline".data(using: .utf8))

        let saved = try store.saveCompletedSession(
            originalImageData: original,
            redlinedImageData: redline,
            feedbackText: "Widen the shoulders slightly."
        )

        let loaded = try store.loadSessions()
        XCTAssertEqual(loaded, [saved])
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.imageURL(for: saved.originalImagePath).path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.imageURL(for: try XCTUnwrap(saved.redlinedImagePath)).path))

        try store.deleteSession(id: saved.id)
        XCTAssertTrue(try store.loadSessions().isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.imageURL(for: saved.originalImagePath).path))
    }
}
