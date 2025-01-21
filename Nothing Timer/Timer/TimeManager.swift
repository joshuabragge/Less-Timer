import Foundation
import AVFoundation
import UserNotifications

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
    private var lastMinuteNotification: Int = 0
    
    init(audioService: AudioServiceProtocol = AudioService(),
        notificationService: NotificationServiceProtocol = NotificationService()) {
        self.audioService = audioService
        self.notificationService = notificationService
        
        setupServices()
    }
    
    private func setupServices() {
        // Move audio setup to be done immediately
        audioService.setupAudioSession()
        audioService.loadSound(named: "bell_ring", withExtension: "mp3")
        // Move notification setup to background
       // DispatchQueue.global(qos: .background).async {
         //       self.notificationService.requestAuthorization()
        //}
    }
    
    func startTimer() {
        if !isRunning {
            // Start the timer immediately
            isRunning = true
            wasStopped = false
            wasReset = false
            startTime = Date().addingTimeInterval(-elapsedTime)
            
            // Setup timer immediately
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)
            
            // Play sound after timer is set up
            DispatchQueue.main.async {
                self.audioService.playSound()
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
        elapsedTime = 0
        wasReset = false
        isRunning = false
        lastMinuteNotification = 0
        wasStopped = false
    }
    
    private func updateTimer() {
            guard let startTime = startTime else { return }
            elapsedTime = Date().timeIntervalSince(startTime)
            
            let currentMinute = Int(elapsedTime / 60)
            if currentMinute > lastMinuteNotification {
                DispatchQueue.main.async {
                    self.audioService.playSound()
                }
                lastMinuteNotification = currentMinute
            }
        }
    }
