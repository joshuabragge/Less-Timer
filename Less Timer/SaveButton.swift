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
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 35, height: 30    )
                    .foregroundColor(color)
                    .opacity(1)
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    HStack {
        SaveButton(icon: "heart.circle.fill", color: .red) {}
        SaveButton(icon: "heart.fill", color: .red) {}
    }
}
