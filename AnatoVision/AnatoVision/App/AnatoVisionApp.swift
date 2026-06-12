import SwiftUI

@main
struct AnatoVisionApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: ReviewSessionViewModel(
                    reviewer: AppEnvironment.makeReviewer(),
                    store: ReviewSessionStore()
                )
            )
        }
    }
}
