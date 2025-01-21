import SwiftUI

struct TimerDisplay: View {
    let timeInterval: TimeInterval
    
    private var timeComponents: (hours: Int, minutes: Int, seconds: Int) {
        TimeFormatter.components(from: timeInterval)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hours
            if timeComponents.hours > 0 {
                Text(TimeFormatter.formatComponent(timeComponents.hours, unit: "hour"))
                    .transition(.opacity)
            }
            
            // Minutes
            if timeComponents.minutes > 0 || timeComponents.hours > 0 {
                Text(TimeFormatter.formatComponent(timeComponents.minutes, unit: "minute"))
                    .transition(.opacity)
            }
            
            // Seconds (always shown)
            Text(TimeFormatter.formatComponent(timeComponents.seconds, unit: "second"))
        }
        .font(.system(size: 40, weight: .medium, design: .rounded))
        .foregroundColor(.gray)
        .frame(minWidth: 200, alignment: .leading)
        .padding()
        .accessibilityLabel("Timer showing \(timeComponents.hours) hours, \(timeComponents.minutes) minutes, and \(timeComponents.seconds) seconds")
        .animation(.easeInOut, value: timeComponents.hours)
        .animation(.easeInOut, value: timeComponents.minutes)
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerDisplay(timeInterval: 3881) // 1 hour, 1 minute, 1 second
    }
}
