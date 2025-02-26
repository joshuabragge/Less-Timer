import SwiftUI

struct TimerDisplay: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.displayScale) var displayScale
    
    let timeInterval: TimeInterval
    let totalTime: TimeInterval?
    
    private var timeComponents: (hours: Int, minutes: Int, seconds: Int) {
        TimeFormatter.components(from: timeInterval)
    }
    
    private var progress: Double {
        guard let total = totalTime, total > 0 else { return 0 }
        return timeInterval / total
    }
    
    private var isWatch: Bool {
        displayScale >= 2.0 && sizeClass == .compact
    }
    
    private var config: TimerConfig {
        isWatch ? .iOS : .watch
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Progress Circle
                if let total = totalTime {
                    ProgressCircle(progress: progress)
                        .padding(config.circlePadding)
                }
                
                // Timer Display
                VStack(alignment: .center, spacing: config.spacing) {
                    Group {
                        if timeComponents.hours > 0  {
                            Text(TimeFormatter.formatComponent(timeComponents.hours, unit: "hour"))
                        }
                        else if timeComponents.minutes > 0 {
                            Text(TimeFormatter.formatComponent(timeComponents.minutes, unit: "minute"))
                        }
                        else if timeComponents.seconds > 0 {
                            Text(TimeFormatter.formatComponent(timeComponents.seconds, unit: "second"))
                        }
                        else {
                            Color.clear
                        }
                    }
                    .frame(height: config.textHeight)
                }
                .font(.system(size: config.fontSize, weight: .medium, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryFont)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: config.frameHeight)
        .padding(config.viewPadding)
        .accessibilityLabel("Timer showing \(timeComponents.hours) hours, \(timeComponents.minutes) minutes, and \(timeComponents.seconds) seconds")
        .animation(.easeInOut, value: timeComponents.hours)
        .animation(.easeInOut, value: timeComponents.minutes)
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct ProgressCircle: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(Color.adaptivePrimaryFont)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                ))
                .foregroundColor(Color.adaptivePrimaryFont)
                .rotationEffect(.degrees(-90))
        }
    }
}

private struct TimerConfig {
    let frameHeight: CGFloat
    let fontSize: CGFloat
    let textHeight: CGFloat
    let spacing: CGFloat
    let viewPadding: CGFloat
    let circlePadding: CGFloat
    
    static let iOS = TimerConfig(
        frameHeight: 200,
        fontSize: 48,
        textHeight: 120,
        spacing: 8,
        viewPadding: 16,
        circlePadding: -50
    )
    
    static let watch = TimerConfig(
        frameHeight: 150,
        fontSize: 22,
        textHeight: 35,
        spacing: 5,
        viewPadding: 5,
        circlePadding: 0
    )
}

#Preview {
    VStack(spacing: 20) {
        TimerDisplay(timeInterval: 3661, totalTime: 7200)
        TimerDisplay(timeInterval: 59, totalTime: 7200)
        TimerDisplay(timeInterval: 111, totalTime: 7200)
    }
}
