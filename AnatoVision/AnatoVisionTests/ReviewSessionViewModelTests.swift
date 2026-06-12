import XCTest
@testable import AnatoVision

@MainActor
final class ReviewSessionViewModelTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func tearDownWithError() throws {
        for directory in temporaryDirectories where FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
    }

    func testAnalyzeSuccessSavesSession() async throws {
        let store = ReviewSessionStore(rootDirectory: makeTemporaryDirectory())
        let reviewer = StubReviewer(result: ReviewResult(redlinedImageData: Data("redline".utf8), feedbackText: "The pose has a clear flow."))
        let viewModel = ReviewSessionViewModel(reviewer: reviewer, store: store)

        viewModel.analyze(imageData: Data("image".utf8))
        try await waitFor {
            if case .result = viewModel.analysisState {
                return true
            }
            return false
        }

        XCTAssertEqual(viewModel.sessions.count, 1)
        XCTAssertEqual(viewModel.sessions.first?.feedbackText, "The pose has a clear flow.")
        XCTAssertEqual(viewModel.analysisState, .result(try XCTUnwrap(viewModel.sessions.first)))
    }

    func testAnalyzeFailureShowsError() async throws {
        let store = ReviewSessionStore(rootDirectory: makeTemporaryDirectory())
        let reviewer = StubReviewer(error: AnatomyReviewError.invalidResponse)
        let viewModel = ReviewSessionViewModel(reviewer: reviewer, store: store)

        viewModel.analyze(imageData: Data("image".utf8))
        try await waitFor {
            if case .failed = viewModel.analysisState {
                return true
            }
            return false
        }

        XCTAssertTrue(viewModel.sessions.isEmpty)
        if case .failed(let message) = viewModel.analysisState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected failed state.")
        }
    }

    func testFailImageLoadingShowsInvalidImageError() {
        let store = ReviewSessionStore(rootDirectory: makeTemporaryDirectory())
        let viewModel = ReviewSessionViewModel(reviewer: StubReviewer(), store: store)

        viewModel.failImageLoading()

        XCTAssertEqual(viewModel.analysisState, .failed(AnatomyReviewError.invalidImage.localizedDescription))
    }

    private func waitFor(_ predicate: @escaping @MainActor () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            if predicate() {
                return
            }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTFail("Timed out waiting for state change.")
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        temporaryDirectories.append(directory)
        return directory
    }
}

private struct StubReviewer: AnatomyReviewing {
    var result: ReviewResult?
    var error: Error?

    func analyze(imageData: Data) async throws -> ReviewResult {
        if let error {
            throw error
        }
        return result ?? ReviewResult(redlinedImageData: nil, feedbackText: "")
    }
}
