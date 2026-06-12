import XCTest
@testable import AnatoVision

final class WeaknessTrendAnalyzerTests: XCTestCase {
    func testAnalyzeRanksRepeatedFeedbackPatterns() {
        let sessions = [
            makeSession(feedback: "The shoulder and elbow need clearer arm placement."),
            makeSession(feedback: "The torso and pelvis balance feels stiff."),
            makeSession(feedback: "Push the perspective and depth through the lower leg.")
        ]

        let trends = WeaknessTrendAnalyzer.analyze(sessions: sessions)

        XCTAssertEqual(trends.first?.category, "Shoulders and arms")
        XCTAssertEqual(trends.first?.count, 3)
        XCTAssertTrue(trends.contains(WeaknessTrend(category: "Perspective", count: 2)))
    }

    func testAnalyzeReturnsEmptyForNoCompletedFeedback() {
        let sessions = [
            ReviewSession(
                id: UUID(),
                originalImagePath: "original.jpg",
                redlinedImagePath: nil,
                feedbackText: "The shoulder needs work.",
                createdAt: Date(),
                status: .failed
            )
        ]

        XCTAssertTrue(WeaknessTrendAnalyzer.analyze(sessions: sessions).isEmpty)
    }

    private func makeSession(feedback: String) -> ReviewSession {
        ReviewSession(
            id: UUID(),
            originalImagePath: "original.jpg",
            redlinedImagePath: "redline.jpg",
            feedbackText: feedback,
            createdAt: Date(),
            status: .completed
        )
    }
}
