import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager = TimerManager()
    @StateObject private var meditationTracker: MeditationTracker = MeditationTracker()
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                // show timer if paused or stopped
                TimerDisplay(timeInterval: timerManager.elapsedTime)
                .transition(.opacity)
                        }
            else if !timerManager.isRunning && timerManager.elapsedTime == 0 {
                // hide timer before starting session
            }
            else {
                // if running partially hide
                TimerDisplay(timeInterval: timerManager.elapsedTime)
                    .opacity(0.3)
                    .transition(.opacity)
            }
            
            HStack(spacing: 50) {
                TimerButton(
                    icon: timerManager.isRunning ? "pause.fill" : "play.fill",
                    color: .gray
                ) {
                    toggleTimer()
                }.opacity(1)
                
                TimerButton(
                    icon: timerManager.wasStopped ? "arrow.uturn.left" : "stop.fill",
                    color: .gray,
                    action: stopTimer                )
                    .opacity(1)
            
            }
            
            HStack(spacing: 1) {
                SaveButton(
                    icon: "heart.fill",
                    color: meditationTracker.saveSuccess == true ? .red : .gray,
                    action: saveSession,
                    isLoading: meditationTracker.isSaving
                    )
                    .opacity(shouldShowSaveButton ? 1 : 0)
                    .disabled(!shouldShowSaveButton)
        }
        .padding()
        .animation(.easeInOut, value: timerManager.isRunning)
       // .animation(.easeInOut, value: shouldShowSaveButton)
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
        if timerManager.elapsedTime < 1 { return }
        
        else if timerManager.wasStopped {
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
