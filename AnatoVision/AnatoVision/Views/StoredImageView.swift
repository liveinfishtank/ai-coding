import SwiftUI
import UIKit

struct StoredImageView: View {
    let url: URL
    var contentMode: ContentMode = .fit

    var body: some View {
        if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.title2)
                Text("Image unavailable")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
