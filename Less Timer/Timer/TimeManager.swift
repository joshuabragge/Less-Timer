import Foundation
import AVFoundation
import UserNotifications
import SwiftUI

protocol TimerManaging: ObservableObject {
    
    var elapsedTime: TimeInterval { get }
    var isRunning: Bool { get }
    var wasStopped: Bool { get }
    var wasReset: Bool { get }
    func startTimer()
    func pauseTimer()
    func stopTimer()
    func resetTimer()
}


class TimerManager: TimerManaging {
    @Published var elapsedTime: TimeInterval = 56
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var wasStopped = false
    @Published var wasReset = true
    
    private var timer: Timer?
    private var startTime: Date?
    private let audioService: AudioServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private var lastChimeMinute: Int = 0
    
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    @AppStorage("isStartSoundEnabled") private var isStartSoundEnabled = true
    
    init(audioService: AudioServiceProtocol = AudioService(),
         notificationService: NotificationServiceProtocol = NotificationService()) {
        self.audioService = audioService
        self.notificationService = notificationService
        self.remainingTime = TimeInterval(timeLimitMinutes * 60)
        setupServices()
        }

    
    private func setupServices() {
            audioService.setupAudioSession()
            audioService.loadSound(named: "chime-ship-bell-single-ring", withExtension: "mp3", identifier: "chime")
            audioService.loadSound(named: "session-end-copper-bell-ding", withExtension: "mp3", identifier: "session-end")
        }
    
    func refreshStorageVariables() {
            // Force refresh from UserDefaults
            isRecurringChimeEnabled = UserDefaults.standard.bool(forKey: "isRecurringChimeEnabled")
            chimeIntervalMinutes = UserDefaults.standard.integer(forKey: "chimeIntervalMinutes")
            isTimeLimitEnabled = UserDefaults.standard.bool(forKey: "isTimeLimitEnabled")
            timeLimitMinutes = UserDefaults.standard.integer(forKey: "timeLimitMinutes")
            isStartSoundEnabled = UserDefaults.standard.bool(forKey: "isStartSoundEnabled")
            
            // Update remaining time if needed
            if isTimeLimitEnabled && wasReset {
                remainingTime = TimeInterval(timeLimitMinutes * 60)
            }
        }


    
    func startTimer() {
        if !isRunning {
            print("Starting timer")
            //play sound on reset if enabled
            if isStartSoundEnabled && wasReset {
                print("Play start sound")
                DispatchQueue.main.async {
                    self.audioService.playSound(identifier: "chime")
                }
            }
            
            isRunning = true
            wasStopped = false
            wasReset = false
            
            if isTimeLimitEnabled {
                // For countdown mode, initialize remaining time if it's zero
                if remainingTime == 0 {
                    remainingTime = TimeInterval(timeLimitMinutes * 60)
                }
                // Calculate how much time has already elapsed
                let elapsed = TimeInterval(timeLimitMinutes * 60) - remainingTime
                startTime = Date().addingTimeInterval(-elapsed)
            } else {
                startTime = Date().addingTimeInterval(-elapsedTime)
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)

        }
    }
    
    
    func pauseTimer() {
        print("Pausing timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = false
    }
    
    func stopTimer() {
        print("Stopping timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = true
    }
    
    func resetTimer() {
        print("Resetting timer")
        elapsedTime = 0
        remainingTime = isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : 0
        wasReset = true
        isRunning = false
        lastChimeMinute = 0
        wasStopped = false
    }
    
    private func updateTimer() {
            guard let startTime = startTime else { return }
            
            // Calculate elapsed time for both modes
            let elapsed = Date().timeIntervalSince(startTime)
            elapsedTime = elapsed
            
            // Handle recurring chimes for both timer modes
            if isRecurringChimeEnabled && remainingTime != 0{
                let currentMinute = Int(elapsedTime / 60)
                if currentMinute >= (lastChimeMinute + chimeIntervalMinutes) {
                    DispatchQueue.main.async {
                        print("Play chime")
                        self.audioService.playSound(identifier: "chime")
                    }
                    lastChimeMinute = currentMinute
                }
            }
            
            // Handle time limit specific logic
            if isTimeLimitEnabled {
                remainingTime = max(TimeInterval(timeLimitMinutes * 60) - elapsed, 0)
                
                // Check if timer has reached zero
                if remainingTime == 0 {
                    stopTimer()
                    DispatchQueue.main.async {
                        print("Playing session end")
                        self.audioService.playSound(identifier: "session-end")
                    }
                    return
                }
            }
        }
}
