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
    @Published var isRunning = false
    @Published var wasStopped = false
    @Published var wasReset = false
    
    private var timer: Timer?
    private var startTime: Date?
    private let audioService: AudioServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private var lastChimeMinute: Int = 0
    
    // init the user settings settings
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    @AppStorage("isStartSoundEnabled") private var isStartSoundEnabled = true
    
    init(audioService: AudioServiceProtocol = AudioService(),
        notificationService: NotificationServiceProtocol = NotificationService()) {
        self.audioService = audioService
        self.notificationService = notificationService
        
        setupServices()
    }
    
    private func setupServices() {
        audioService.setupAudioSession()
        audioService.loadSound(named: "bell_ring", withExtension: "mp3")
        // Move notification setup to background
       // DispatchQueue.global(qos: .background).async {
         //       self.notificationService.requestAuthorization()
        //}
    }
    
    func startTimer() {
        if !isRunning {
            
            // Start the timer and reset parameters
            isRunning = true
            wasStopped = false
            wasReset = false
            startTime = Date().addingTimeInterval(-elapsedTime)
            
            // Setup timer immediately
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)
            
            print(isStartSoundEnabled)
            if isStartSoundEnabled {
                print("Playing starting sound")
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
        wasStopped = false  // Mark that we're paused, not stopped
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = true
    }
    
    func resetTimer() {
        //let isStartingSoundEnabled = UserDefaults.standard.bool(forKey: "isStartingSoundEnabled")
        elapsedTime = 0
        wasReset = false
        isRunning = false
        lastChimeMinute = 0
        wasStopped = false
    }
    
    private func updateTimer() {
            guard let startTime = startTime else { return }
            elapsedTime = Date().timeIntervalSince(startTime)
            
            // Only play chimes if enabled
            if isRecurringChimeEnabled {
                let currentMinute = Int(elapsedTime / 60)
                
                // Check if we've reached the next interval
                if currentMinute >= (lastChimeMinute + chimeIntervalMinutes) {
                    DispatchQueue.main.async {
                        self.audioService.playSound()
                    }
                    print("Chime played!")
                    lastChimeMinute = currentMinute
                }
            }
        }
    }
