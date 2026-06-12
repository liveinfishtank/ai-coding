import PhotosUI
import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var viewModel: ReviewSessionViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    init(viewModel: ReviewSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedSession) {
                if viewModel.sessions.isEmpty {
                    EmptyHistoryView()
                        .listRowSeparator(.hidden)
                } else {
                    if !viewModel.weaknessTrends.isEmpty {
                        Section("Common Patterns") {
                            ForEach(viewModel.weaknessTrends) { trend in
                                TrendRow(trend: trend)
                            }
                        }
                    }

                    Section("Review History") {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(value: session) {
                                HistoryRow(session: session, imageURL: viewModel.originalImageURL(for: session))
                            }
                        }
                        .onDelete(perform: viewModel.deleteSessions)
                    }
                }
            }
            .navigationTitle("AnatoVision")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Photos", systemImage: "photo")
                    }

                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            isShowingCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { item in
                Task { await loadPhoto(item) }
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraPicker { image in
                    viewModel.analyze(image: image)
                }
                .ignoresSafeArea()
            }
        } detail: {
            detailContent
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch viewModel.analysisState {
        case .idle:
            if let session = viewModel.selectedSession {
                HistoryDetailView(session: session, viewModel: viewModel)
            } else {
                WelcomeView()
            }
        case .analyzing:
            AnalyzingView(onCancel: viewModel.cancelAnalysis)
        case .result(let session):
            ResultView(session: session, viewModel: viewModel)
        case .failed(let message):
            ErrorStateView(message: message, onRetry: viewModel.retryLastAnalysis)
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.analyze(image: image)
                    selectedPhotoItem = nil
                }
            } else {
                await MainActor.run {
                    viewModel.failImageLoading()
                    selectedPhotoItem = nil
                }
            }
        } catch {
            await MainActor.run {
                viewModel.failImageLoading()
                selectedPhotoItem = nil
            }
        }
    }
}

private struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "figure.mixed.cardio")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(.red)
            Text("Select an image to start a review")
                .font(.title2.weight(.semibold))
            Text("Load a rough sketch or line drawing to see a redline overlay and practical anatomy feedback.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .padding()
    }
}

private struct TrendRow: View {
    let trend: WeaknessTrend

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .foregroundStyle(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(trend.category)
                    .font(.subheadline.weight(.semibold))
                Text("\(trend.count) related notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("No reviews yet", systemImage: "tray")
                .font(.headline)
            Text("Use Photos or Camera to create your first anatomy review.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}

private struct HistoryRow: View {
    let session: ReviewSession
    let imageURL: URL

    var body: some View {
        HStack(spacing: 12) {
            StoredImageView(url: imageURL, contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(session.createdAt, style: .date)
                    .font(.headline)
                Text(session.feedbackText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
