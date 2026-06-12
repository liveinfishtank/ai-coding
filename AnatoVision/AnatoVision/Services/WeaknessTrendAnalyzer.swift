import Foundation

enum WeaknessTrendAnalyzer {
    private static let rules: [(category: String, keywords: [String])] = [
        ("Shoulders and arms", ["shoulder", "elbow", "arm", "wrist", "hand"]),
        ("Torso balance", ["torso", "rib", "waist", "spine", "chest", "pelvis"]),
        ("Perspective", ["perspective", "depth", "foreshorten", "angle", "space"]),
        ("Lower body", ["knee", "ankle", "foot", "leg", "hip"]),
        ("Gesture flow", ["flow", "gesture", "pose", "weight", "balance"])
    ]

    static func analyze(sessions: [ReviewSession], limit: Int = 3) -> [WeaknessTrend] {
        let feedback = sessions
            .filter { $0.status == .completed }
            .map(\.feedbackText)
            .joined(separator: " ")
            .lowercased()

        guard !feedback.isEmpty else { return [] }

        return rules
            .map { rule in
                let count = rule.keywords.reduce(0) { partial, keyword in
                    partial + occurrences(of: keyword, in: feedback)
                }
                return WeaknessTrend(category: rule.category, count: count)
            }
            .filter { $0.count > 0 }
            .sorted {
                if $0.count == $1.count {
                    return $0.category < $1.category
                }
                return $0.count > $1.count
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func occurrences(of keyword: String, in text: String) -> Int {
        var count = 0
        var searchRange = text.startIndex..<text.endIndex

        while let range = text.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive], range: searchRange) {
            count += 1
            searchRange = range.upperBound..<text.endIndex
        }

        return count
    }
}
