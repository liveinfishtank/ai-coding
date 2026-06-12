import Foundation

final class RemoteAnatomyReviewClient: AnatomyReviewing {
    private let baseURL: URL
    private let bearerToken: String?
    private let session: URLSession

    init(baseURL: URL, bearerToken: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
    }

    func analyze(imageData: Data) async throws -> ReviewResult {
        let url = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("anatomy-reviews")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let bearerToken, !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        let payload = ReviewRequest(imageBase64: imageData.base64EncodedString())
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnatomyReviewError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data), !error.message.isEmpty {
                throw AnatomyReviewError.serverMessage(error.message)
            }
            throw AnatomyReviewError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data)
        guard let redlineData = try await resolveRedlineData(from: decoded) else {
            throw AnatomyReviewError.missingRedline
        }
        return ReviewResult(redlinedImageData: redlineData, feedbackText: decoded.feedbackText)
    }

    private func resolveRedlineData(from response: ReviewResponse) async throws -> Data? {
        if let base64 = response.redlinedImageBase64, !base64.isEmpty {
            guard let data = Data(base64Encoded: base64) else {
                throw AnatomyReviewError.invalidResponse
            }
            return data
        }

        if let urlString = response.redlinedImageURL, let url = URL(string: urlString) {
            let (data, _) = try await session.data(from: url)
            return data
        }

        return nil
    }
}

private struct ReviewRequest: Codable {
    let imageBase64: String
}

struct ReviewResponse: Codable, Equatable {
    let redlinedImageBase64: String?
    let redlinedImageURL: String?
    let feedbackText: String
}

private struct ErrorResponse: Codable {
    let message: String
}
