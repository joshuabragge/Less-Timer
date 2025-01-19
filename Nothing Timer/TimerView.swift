import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager = TimerManager()
    @StateObject private var meditationTracker: MeditationTracker = MeditationTracker()
    
    var body: some View {
        VStack(spacing: 100) {
            Spacer()
            
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
                    action: stopTimer                )
            
            }
            
            HStack(spacing: 30) {
                SaveButton(
                    icon: "heart.circle.fill",
                    color: meditationTracker.saveSuccess == true ? .red : .gray,
                    action: saveSession,
                    isLoading: meditationTracker.isSaving
                    )
                    .opacity(shouldShowSaveButton ? 1 : 0)
                    .disabled(!shouldShowSaveButton)
        }
        .padding()
        .animation(.easeInOut, value: timerManager.isRunning)
        .animation(.easeInOut, value: shouldShowSaveButton)
        }
    }
    
    private var shouldShowSaveButton: Bool {
            timerManager.wasStopped && !timerManager.wasReset && timerManager.elapsedTime > 0
        }
    
    
    private func saveSession() {
        print("SAVING")
        meditationTracker.saveMeditationSession(duration: timerManager.elapsedTime)
        print("RESETING")
        timerManager.resetTimer()
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
