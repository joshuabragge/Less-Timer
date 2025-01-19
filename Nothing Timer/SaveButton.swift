import SwiftUI

struct SaveButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .frame(width: 100, height: 100)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(color)
                    .opacity(0.8)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    HStack {
        SaveButton(icon: "heart.circle.fill", color: .red) {}
    }
}
