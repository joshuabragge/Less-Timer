import SwiftUI

struct TimerButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(color)
                .opacity(1)  // Slightly transparent
        }
    }
}

#Preview {
    HStack {
        TimerButton(icon: "play.fill", color: .gray) {}
        TimerButton(icon: "arrow.counterclockwise.circle.fill", color: .gray) {}
    }
}
