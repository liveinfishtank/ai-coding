import Foundation

struct WeaknessTrend: Identifiable, Equatable {
    let category: String
    let count: Int

    var id: String { category }
}
