import Foundation

enum AppEnvironment {
    static func makeReviewer() -> AnatomyReviewing {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "ANATOVISION_API_BASE_URL") as? String,
            let url = URL(string: value),
            !value.isEmpty
        else {
            return MockAnatomyReviewClient()
        }

        let token = Bundle.main.object(forInfoDictionaryKey: "ANATOVISION_API_BEARER_TOKEN") as? String
        return RemoteAnatomyReviewClient(baseURL: url, bearerToken: token)
    }
}
