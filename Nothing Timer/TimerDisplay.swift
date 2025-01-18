import SwiftUI

struct TimerDisplay: View {
    let timeInterval: TimeInterval
    
    var body: some View {
        Text(TimeFormatter.string(from: timeInterval))
            .font(.system(size: 60, weight: .medium, design: .monospaced))
            .foregroundColor(.gray)  // Subtle gray color
            .frame(minWidth: 200)
            .padding()
            .accessibilityLabel("Timer showing \(TimeFormatter.string(from: timeInterval))")
    }
}

#Preview {
    TimerDisplay(timeInterval: 3661) // Shows 01:01:01
}
