import SwiftUI

struct AnalyzingView: View {
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .controlSize(.large)
            Text("Reviewing anatomy and perspective")
                .font(.title3.weight(.semibold))
            Text("Complex images or slow networks may take a little longer.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            Button(role: .cancel, action: onCancel) {
                Label("Cancel", systemImage: "xmark.circle")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
