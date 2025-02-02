import SwiftUI

struct AppStorePreview<Content: View>: View {
    let content: Content
    let title: String
    let subtitle: String
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        ZStack {
            // Main content
            content
            
            VStack {
                // Marketing text overlay
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
            }
        }
    }
}

// Usage example for previews
#Preview {
    AppStoreScreenshots()
}
