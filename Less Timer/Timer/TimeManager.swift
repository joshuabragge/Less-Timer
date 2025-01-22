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
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var wasStopped = false
    @Published var wasReset = false
    
    private var timer: Timer?
    private var startTime: Date?
    private let audioService: AudioServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let hapticService: HapticServiceProtocol
    private var lastChimeMinute: Int = 0
    
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    @AppStorage("isStartSoundEnabled") private var isStartSoundEnabled = true
    
    init(audioService: AudioServiceProtocol = AudioService(),
         notificationService: NotificationServiceProtocol = NotificationService(),
         hapticService: HapticServiceProtocol = HapticService()) {
        self.audioService = audioService
        self.notificationService = notificationService
        self.hapticService = hapticService
        self.remainingTime = TimeInterval(timeLimitMinutes * 60)
        setupServices()
        }

    
    private func setupServices() {
        audioService.setupAudioSession()
        audioService.loadSound(named: "bell_ring", withExtension: "mp3")
    }
    
    func startTimer() {
        if !isRunning {
            isRunning = true
            wasStopped = false
            wasReset = false
            
            if isTimeLimitEnabled {
                // For countdown mode, initialize remaining time if it's zero
                if remainingTime == 0 {
                    remainingTime = TimeInterval(timeLimitMinutes * 60)
                }
                startTime = Date()
            } else {
                startTime = Date().addingTimeInterval(-elapsedTime)
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)
            
            if isStartSoundEnabled {
                DispatchQueue.main.async {
                    self.audioService.playSound()
                }
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = false
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = true
    }
    
    func resetTimer() {
        elapsedTime = 0
        remainingTime = isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : 0
        wasReset = false
        isRunning = false
        lastChimeMinute = 0
        wasStopped = false
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        if isTimeLimitEnabled {
            // Update countdown timer
            let elapsed = Date().timeIntervalSince(startTime)
            remainingTime = max(TimeInterval(timeLimitMinutes * 60) - elapsed, 0)
            elapsedTime = elapsed
            
            // Check if timer has reached zero
            if remainingTime == 0 {
                stopTimer()
                DispatchQueue.main.async {
                    self.audioService.playSound()
                    self.hapticService.vibrate() // Strong vibration for time completion
                    self.hapticService.playNotificationHaptic(type: .success) // Additional haptic feedback
                }
                return
            }
        } else {
            // Update count-up timer
            elapsedTime = Date().timeIntervalSince(startTime)
            
            // Handle recurring chimes
            if isRecurringChimeEnabled {
                let currentMinute = Int(elapsedTime / 60)
                if currentMinute >= (lastChimeMinute + chimeIntervalMinutes) {
                    DispatchQueue.main.async {
                        self.audioService.playSound()
                        self.hapticService.playHapticImpact(style: .light)
                    }
                    lastChimeMinute = currentMinute
                }
            }
        }
    }
}
