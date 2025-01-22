import SwiftUI

struct TimerDisplay: View {
    let timeInterval: TimeInterval
    
    private var timeComponents: (hours: Int, minutes: Int, seconds: Int) {
        TimeFormatter.components(from: timeInterval)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 8) {
                // Hours - Using fixed height placeholder when hidden
                Group {
                    if timeComponents.hours > 0 {
                        Text(TimeFormatter.formatComponent(timeComponents.hours, unit: "hour"))
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 48) // Match font line height
                
                // Minutes - Using fixed height placeholder when hidden
                Group {
                    if timeComponents.minutes > 0 || timeComponents.hours > 0 {
                        Text(TimeFormatter.formatComponent(timeComponents.minutes, unit: "minute"))
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 48)
                
                // Seconds (always shown)
                Text(TimeFormatter.formatComponent(timeComponents.seconds, unit: "second"))
                    .frame(height: 48)
            }
            .font(.system(size: 40, weight: .medium, design: .rounded))
            .foregroundColor(.gray)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center
            )
        }
        .frame(height: 200)  // Fixed height for the entire component
        .padding()
        .accessibilityLabel("Timer showing \(timeComponents.hours) hours, \(timeComponents.minutes) minutes, and \(timeComponents.seconds) seconds")
        .animation(.easeInOut, value: timeComponents.hours)
        .animation(.easeInOut, value: timeComponents.minutes)
        .transaction { transaction in
            // Disable animation for seconds to prevent jitter
            transaction.animation = nil
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerDisplay(timeInterval: 60) // 1 hour, 1 minute, 1 second
    }
}
