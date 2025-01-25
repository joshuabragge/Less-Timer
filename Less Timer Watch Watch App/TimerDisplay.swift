// WatchTimerDisplay.swift
import SwiftUI

struct TimerDisplay: View {
    let timeInterval: TimeInterval
    
    private var timeComponents: (hours: Int, minutes: Int, seconds: Int) {
        TimeFormatter.components(from: timeInterval)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if timeComponents.hours > 0 {
                Text(TimeFormatter.formatComponent(timeComponents.hours, unit: "hour"))
                    .font(.system(.title3, design: .rounded))
            }
            
            if timeComponents.minutes > 0 || timeComponents.hours > 0 {
                Text(TimeFormatter.formatComponent(timeComponents.minutes, unit: "minute"))
                    .font(.system(.title3, design: .rounded))
            }
            
            Text(TimeFormatter.formatComponent(timeComponents.seconds, unit: "second"))
                .font(.system(.title3, design: .rounded))
        }
        .foregroundColor(.gray)
    }
}
