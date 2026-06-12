import Foundation
import UIKit

@MainActor
final class ReviewSessionViewModel: ObservableObject {
    enum AnalysisState: Equatable {
        case idle
        case analyzing
        case result(ReviewSession)
        case failed(String)
    }

    @Published private(set) var sessions: [ReviewSession] = []
    @Published private(set) var analysisState: AnalysisState = .idle
    @Published var selectedSession: ReviewSession?

    var weaknessTrends: [WeaknessTrend] {
        WeaknessTrendAnalyzer.analyze(sessions: sessions)
    }

    private let reviewer: AnatomyReviewing
    private let store: ReviewSessionStore
    private var lastImageData: Data?
    private var analysisTask: Task<Void, Never>?

    init(reviewer: AnatomyReviewing, store: ReviewSessionStore) {
        self.reviewer = reviewer
        self.store = store
        refreshSessions()
    }

    func refreshSessions() {
        do {
            sessions = try store.loadSessions()
        } catch {
            analysisState = .failed("History could not be loaded.")
        }
    }

    func analyze(image: UIImage) {
        do {
            let data = try ImageProcessor.normalizedJPEGData(from: image)
            analyze(imageData: data)
        } catch {
            analysisState = .failed(error.localizedDescription)
        }
    }

    func analyze(imageData: Data) {
        lastImageData = imageData
        analysisTask?.cancel()
        analysisState = .analyzing

        analysisTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await reviewer.analyze(imageData: imageData)
                try Task.checkCancellation()
                let session = try store.saveCompletedSession(
                    originalImageData: imageData,
                    redlinedImageData: result.redlinedImageData,
                    feedbackText: result.feedbackText
                )
                sessions = try store.loadSessions()
                selectedSession = session
                analysisState = .result(session)
            } catch is CancellationError {
                analysisState = .idle
            } catch {
                analysisState = .failed(error.localizedDescription)
            }
        }
    }

    func retryLastAnalysis() {
        guard let lastImageData else {
            analysisState = .failed("There is no image available to retry.")
            return
        }
        analyze(imageData: lastImageData)
    }

    func failImageLoading() {
        analysisState = .failed(AnatomyReviewError.invalidImage.localizedDescription)
    }

    func cancelAnalysis() {
        analysisTask?.cancel()
        analysisTask = nil
        analysisState = .idle
    }

    func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            try? store.deleteSession(id: session.id)
            if selectedSession?.id == session.id {
                selectedSession = nil
            }
        }
        refreshSessions()
    }

    func originalImageURL(for session: ReviewSession) -> URL {
        store.imageURL(for: session.originalImagePath)
    }

    func redlinedImageURL(for session: ReviewSession) -> URL? {
        session.redlinedImagePath.map(store.imageURL(for:))
    }
}
