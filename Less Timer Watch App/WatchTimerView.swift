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
                    if !timerManager.isRunning && timerManager.elapsedTime == 0 {
                        if !isTimeLimitEnabled {
                            // Open-ended meditation display
                            Image(systemName: "infinity")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        } else {
                            // Countdown display before starting
                            TimerDisplay(timeInterval: TimeInterval(timeLimitMinutes * 60))
                        }
                    } else {
                        // Running or paused display
                        TimerDisplay(
                            timeInterval: isTimeLimitEnabled ? timerManager.remainingTime : timerManager.elapsedTime
                        )
                        .opacity(timerManager.isRunning ? 0.3 : 1.0)
                    }
                }
                
                Spacer()
                
                // Control Buttons
                HStack {
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.startTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.gray)
                            
                    }
                    
                    Button(action: {
                        if timerManager.wasStopped {
                            timerManager.resetTimer()
                        } else {
                            timerManager.stopTimer()
                        }
                    }) {
                        Image(systemName: timerManager.wasStopped ? "arrow.uturn.left.circle.fill" : "stop.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.gray)
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
                            .foregroundColor(meditationTracker.saveSuccess == true ? .red : .gray)
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
