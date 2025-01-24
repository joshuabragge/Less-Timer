import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager: TimerManager = TimerManager()
    @StateObject private var meditationTracker: MeditationTracker = MeditationTracker()
    
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    @State private var showIcon = true
    @State private var firstLaunch = true
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            Spacer()
            
            ZStack {
                // Icon view
                if showIcon && firstLaunch {
                    Image("less-timer-icon-clear.png")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                        .opacity(showIcon ? 1 : 0)
                        .transition(.opacity)
                }
                
                // Timer display
                Group {
                    if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                        TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                    } else if isTimeLimitEnabled && !timerManager.isRunning && timerManager.elapsedTime == 0 {
                        TimerDisplay(timeInterval: TimeInterval(timeLimitMinutes * 60))
                    } else if timerManager.isRunning {
                        TimerDisplay(timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime)
                            .opacity(0.3)
                    }
                }
                .opacity(showIcon ? 0 : 1)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            withAnimation(.easeOut(duration: 1)) {
                                showIcon = false
                                firstLaunch = false
                            }
                        }
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
