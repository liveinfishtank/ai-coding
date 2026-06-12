import Foundation

final class ReviewSessionStore {
    private let fileManager: FileManager
    private let rootDirectory: URL
    private let imagesDirectory: URL
    private let indexURL: URL

    init(fileManager: FileManager = .default, rootDirectory: URL? = nil) {
        self.fileManager = fileManager
        let base = rootDirectory ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.rootDirectory = base.appendingPathComponent("AnatoVisionData", isDirectory: true)
        self.imagesDirectory = self.rootDirectory.appendingPathComponent("Images", isDirectory: true)
        self.indexURL = self.rootDirectory.appendingPathComponent("sessions.json")
    }

    func loadSessions() throws -> [ReviewSession] {
        try ensureDirectories()
        guard fileManager.fileExists(atPath: indexURL.path) else { return [] }
        let data = try Data(contentsOf: indexURL)
        return try JSONDecoder.sessionDecoder.decode([ReviewSession].self, from: data)
            .sorted { $0.createdAt > $1.createdAt }
    }

    func saveCompletedSession(originalImageData: Data, redlinedImageData: Data?, feedbackText: String) throws -> ReviewSession {
        try ensureDirectories()
        var sessions = try loadSessions()
        let id = UUID()
        let originalName = "\(id.uuidString)-original.jpg"
        let redlineName = redlinedImageData == nil ? nil : "\(id.uuidString)-redline.jpg"

        try originalImageData.write(to: imagesDirectory.appendingPathComponent(originalName), options: .atomic)
        if let redlinedImageData, let redlineName {
            try redlinedImageData.write(to: imagesDirectory.appendingPathComponent(redlineName), options: .atomic)
        }

        let session = ReviewSession(
            id: id,
            originalImagePath: "Images/\(originalName)",
            redlinedImagePath: redlineName.map { "Images/\($0)" },
            feedbackText: feedbackText,
            createdAt: Date(),
            status: .completed
        )
        sessions.insert(session, at: 0)
        try persist(sessions)
        return session
    }

    func deleteSession(id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        let session = sessions.remove(at: index)
        try deleteImageIfNeeded(path: session.originalImagePath)
        if let redlinedImagePath = session.redlinedImagePath {
            try deleteImageIfNeeded(path: redlinedImagePath)
        }
        try persist(sessions)
    }

    func imageURL(for path: String) -> URL {
        rootDirectory.appendingPathComponent(path)
    }

    private func ensureDirectories() throws {
        try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }

    private func persist(_ sessions: [ReviewSession]) throws {
        let data = try JSONEncoder.sessionEncoder.encode(sessions)
        try data.write(to: indexURL, options: .atomic)
    }

    private func deleteImageIfNeeded(path: String) throws {
        let url = imageURL(for: path)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}

private extension JSONEncoder {
    static var sessionEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var sessionDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
