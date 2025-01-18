import SwiftUI

struct TimerButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(color)
                .opacity(0.8)  // Slightly transparent
        }
    }
}

#Preview {
    HStack {
        TimerButton(icon: "play.circle.fill", color: .gray) {}
        TimerButton(icon: "arrow.counterclockwise.circle.fill", color: .gray) {}
    }
}
