import SwiftUI
import OSLog

struct TimerView: View {
    init(haptics: HapticServiceProtocol = HapticManager.shared) {
        self.haptics = haptics
    }
    @StateObject private var timerManager: TimerManager = TimerManager()
    @StateObject private var meditationTracker: MeditationTracker = MeditationTracker()
    
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    private let haptics: HapticServiceProtocol
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            Spacer()
            ZStack {
                // Timer display
                Group {
                    if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                        // Paused view
                        TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                        
                    }
                    else if !timerManager.isRunning && timerManager.elapsedTime == 0 {
                        if !isTimeLimitEnabled {
                            /// Pending start open ended view
                            Image(systemName: "infinity")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        else {
                            /// Pending start timed view
                            TimerDisplay(timeInterval: TimeInterval(timeLimitMinutes * 60))
                        }
                    }
                    else if timerManager.isRunning {
                        /// Running view
                        TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                            .opacity(0.3)
                    }
                }
            }
            Spacer()
            HStack(spacing: 50) {
                TimerButton(
                    icon: timerManager.isRunning ? "pause.fill" : "play",
                    color: .white
                ) {
                    toggleTimer()
                }.opacity(1)
                
                TimerButton(
                    icon: timerManager.wasStopped ? "arrow.uturn.left" : "stop",
                    color: .white,
                    action: stopTimer
                )
            }
            
            HStack(spacing: 1) {
                SaveButton(
                    icon: "heart.fill",
                    color: meditationTracker.saveSuccess == true ? .red : .white,
                    action: {
                        HapticManager.shared.playSuccess()
                        saveSession()
                    },
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
