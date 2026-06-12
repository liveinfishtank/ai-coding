import Foundation

protocol AnatomyReviewing {
    func analyze(imageData: Data) async throws -> ReviewResult
}

enum AnatomyReviewError: LocalizedError, Equatable {
    case invalidImage
    case invalidResponse
    case serverMessage(String)
    case missingRedline

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image could not be loaded. Please try another image."
        case .invalidResponse:
            return "The anatomy review service returned an unexpected response."
        case .serverMessage(let message):
            return message
        case .missingRedline:
            return "The redline image could not be retrieved."
        }
    }
}
