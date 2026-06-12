import SwiftUI

struct ResultView: View {
    let session: ReviewSession
    @ObservedObject var viewModel: ReviewSessionViewModel
    @State private var selectedImage = ComparisonImage.redline

    var body: some View {
        ReviewDetailLayout(
            title: "Review Result",
            session: session,
            originalURL: viewModel.originalImageURL(for: session),
            redlineURL: viewModel.redlinedImageURL(for: session),
            selectedImage: $selectedImage
        )
    }
}

struct HistoryDetailView: View {
    let session: ReviewSession
    @ObservedObject var viewModel: ReviewSessionViewModel
    @State private var selectedImage = ComparisonImage.redline

    var body: some View {
        ReviewDetailLayout(
            title: "History Detail",
            session: session,
            originalURL: viewModel.originalImageURL(for: session),
            redlineURL: viewModel.redlinedImageURL(for: session),
            selectedImage: $selectedImage
        )
    }
}

enum ComparisonImage: String, CaseIterable, Identifiable {
    case original = "Original"
    case redline = "Redline"

    var id: String { rawValue }
}

private struct ReviewDetailLayout: View {
    let title: String
    let session: ReviewSession
    let originalURL: URL
    let redlineURL: URL?
    @Binding var selectedImage: ComparisonImage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.title.bold())
                            Text(session.createdAt, format: .dateTime.year().month().day().hour().minute())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    }

                    Picker("Image", selection: $selectedImage) {
                        ForEach(ComparisonImage.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                }

                imageContent
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 320)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 10) {
                    Label("Improvement Notes", systemImage: "text.bubble")
                        .font(.headline)
                    Text(session.feedbackText)
                        .font(.body)
                        .lineSpacing(5)
                        .textSelection(.enabled)
                }
                .padding()
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
        .navigationTitle(title)
    }

    @ViewBuilder
    private var imageContent: some View {
        let url = selectedImage == .original ? originalURL : (redlineURL ?? originalURL)
        StoredImageView(url: url, contentMode: .fit)
            .padding(8)
    }
}
