import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager = TimerManager()
    @StateObject private var meditationTracker: MeditationTracker = MeditationTracker()
    
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            Spacer()
            // Display logic for different timer states
            if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                // Show elapsed time when paused or stopped
                TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                    .transition(.opacity)
            }
            // Show initial time limit when enabled and not started
            else if isTimeLimitEnabled && !timerManager.isRunning && timerManager.elapsedTime == 0 {
                TimerDisplay(timeInterval: TimeInterval(timeLimitMinutes * 60))
            }
            // Hide timer before starting session when no time limit
            else if !timerManager.isRunning && timerManager.elapsedTime == 0 && !isTimeLimitEnabled {
                // Empty view
            }
            // Show running timer with reduced opacity
            else {
                TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                    .opacity(0.3)
                    .transition(.opacity)
            }
            Spacer()
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
                    action: stopTimer
                )
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
        }
        .padding()
        .animation(.easeInOut, value: timerManager.isRunning)
        .onAppear {
            timerManager.refreshStorageVariables()
        }
    }
    
    private var shouldShowSaveButton: Bool {
        timerManager.wasStopped && !timerManager.wasReset && timerManager.elapsedTime > 0
    }
    
    private func saveSession() {
        meditationTracker.saveMeditationSession(duration: timerManager.elapsedTime)
        timerManager.resetTimer()
    }
    
    private func toggleTimer() {
        if timerManager.isRunning {
            timerManager.pauseTimer()
        } else {
            timerManager.startTimer()
        }
    }
    
    private func stopTimer() {
        if timerManager.elapsedTime < 1 { return }
        
        if timerManager.wasStopped {
            timerManager.resetTimer()
        } else {
            timerManager.stopTimer()
        }
    }
}
#Preview {
    TimerView()
}
