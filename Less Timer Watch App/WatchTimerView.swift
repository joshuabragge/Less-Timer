// WatchTimerView.swift
import SwiftUI

struct WatchTimerView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var meditationTracker = MeditationTracker()
    
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = true
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    var body: some View {
        TabView {
            // Timer Tab
            VStack {
                Spacer()
                
                // Timer Display
                ZStack {
                    // Timer display
                    Group {
                        if !timerManager.isRunning && timerManager.elapsedTime > 0 {
                            // Paused view
                            TimerDisplay(
                                timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime,
                                totalTime: isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : nil
                            )
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
                                TimerDisplay(
                                    timeInterval: TimeInterval(timeLimitMinutes * 60),
                                    totalTime: TimeInterval(timeLimitMinutes * 60)
                                )
                            }
                        }
                        else if timerManager.isRunning {
                            /// Running view
                            TimerDisplay(
                                timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime,
                                totalTime: isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : nil
                            )
                            .opacity(0.3)
                        }
                    }
                }
                
                Spacer()
                
                // Control Buttons
                HStack {
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.refreshStorageVariables()
                            timerManager.startTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.circle" : "play.circle")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        if timerManager.wasStopped {
                            timerManager.resetTimer()
                        } else {
                            timerManager.stopTimer()
                        }
                    }) {
                        Image(systemName: timerManager.wasStopped ? "arrow.uturn.left.circle" : "stop.circle")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            
                    }
                }
                
                // Save Button
                if timerManager.wasStopped && !timerManager.wasReset {
                    Button(action: {
                        meditationTracker.saveMeditationSession(duration: timerManager.elapsedTime)
                        timerManager.resetTimer()
                    }) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(meditationTracker.saveSuccess == true ? .red : .white)
                    }
                    .disabled(meditationTracker.isSaving)
                }
            }
            .tabItem {
                Label("Timer", systemImage: "timer")
            }
            
            // Settings Tab
            WatchSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }.onAppear {
            //timerManager.refreshStorageVariables()
        }
    }
}
#Preview {
    ContentView()
}
