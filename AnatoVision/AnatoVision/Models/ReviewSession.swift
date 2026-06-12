import Foundation

enum ReviewSessionStatus: String, Codable, Hashable {
    case completed
    case failed
}

struct ReviewSession: Identifiable, Codable, Hashable {
    let id: UUID
    var originalImagePath: String
    var redlinedImagePath: String?
    var feedbackText: String
    var createdAt: Date
    var status: ReviewSessionStatus
}

struct ReviewResult: Equatable {
    var redlinedImageData: Data?
    var feedbackText: String
}
