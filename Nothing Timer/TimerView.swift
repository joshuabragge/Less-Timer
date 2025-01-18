import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager = TimerManager()
    
    var body: some View {
        VStack(spacing: 30) {
            if !timerManager.isRunning {
                            TimerDisplay(timeInterval: timerManager.elapsedTime)
                                .transition(.opacity)
                        }
            
            HStack(spacing: 30) {
                TimerButton(
                    icon: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill",
                    color: .gray
                ) {
                    toggleTimer()
                }
                
                TimerButton(
                    icon: timerManager.wasStopped ? "arrow.counterclockwise.circle.fill" : "stop.circle.fill",
                    color: .gray,
                    action: stopTimer
                )
            }
        }
        .padding()
        .animation(.easeInOut, value: timerManager.isRunning)
    }
    
    private func toggleTimer() {
        if timerManager.isRunning {
            print("PAUSING")
            timerManager.pauseTimer()
        } else {
            print("STARTING")
            timerManager.startTimer()
        }
    }
    
    private func stopTimer() {
        if timerManager.wasStopped {
            print("RESETING")
            timerManager.resetTimer()
        }
        else {
            print("STOPPING")
            timerManager.stopTimer()
        }
    }
}
#Preview {
    TimerView()
}
