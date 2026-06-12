import UIKit

final class MockAnatomyReviewClient: AnatomyReviewing {
    func analyze(imageData: Data) async throws -> ReviewResult {
        guard let image = UIImage(data: imageData) else {
            throw AnatomyReviewError.invalidImage
        }

        try await Task.sleep(nanoseconds: 900_000_000)
        return ReviewResult(
            redlinedImageData: RedlineRenderer.renderRedline(on: image)?.jpegData(compressionQuality: 0.9),
            feedbackText: """
            The shoulder-to-elbow line is drifting inward. Widen the shoulder mass and move the elbow slightly outward to stabilize the torso.

            The rib cage is facing too squarely compared with the pelvis. Add a small twist through the waist so the pose has a clearer flow.

            The foot contact reads well. Strengthen the perspective from knee to ankle to give the lower body more depth.
            """
        )
    }
}
