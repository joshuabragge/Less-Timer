import Foundation
import AVFoundation
import SwiftUI
import OSLog

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
    @Published var elapsedTime: TimeInterval = 50
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var wasStopped = false
    @Published var wasReset = true
    
    /// Keep screen on for watch
    @MainActor private let sessionManager = SessionManager()
    
    private var timer: Timer?
    private var startTime: Date?
    private let audioService: AudioServiceProtocol
    private let logger = Logger.timer
    private var lastChimeMinute: Int = 0
    private let haptics: HapticServiceProtocol
    
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    @AppStorage("isSoundsEnabled") private var isSoundsEnabled = true
    @AppStorage("isVibrationEnabled") private var isVibrationEnabled = true
    
    init(audioService: AudioServiceProtocol = AudioService(),
         haptics: HapticServiceProtocol = HapticManager.shared) {
        self.audioService = audioService
        self.haptics = haptics
        self.remainingTime = TimeInterval(timeLimitMinutes * 60)
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
            isSoundsEnabled = UserDefaults.standard.bool(forKey: "isSoundsEnabled")
            isVibrationEnabled = UserDefaults.standard.bool(forKey: "isVibrationEnabled")
            
            // Update remaining time if needed
            if isTimeLimitEnabled && wasReset {
                remainingTime = TimeInterval(timeLimitMinutes * 60)
            }
        }
    
    func startTimer() {
        if !isRunning {
            DispatchQueue.main.async {
                self.sessionManager.startSession()
            }
            
            logger.info("startTimer: starting background audio")
            self.audioService.startBackgroundAudio()
            logger.info("startTimer: starting timer")
            //play sound on reset if enabled
            if isSoundsEnabled && wasReset {
                logger.info("startTimer: play starting sound")
                DispatchQueue.main.async {
                    self.audioService.playSound(identifier: "session-end")
                }
            }

            logger.info("startTimer: playing start vibration")
            DispatchQueue.main.async {
                self.haptics.playStart()
            }
            
            isRunning = true
            wasStopped = false
            wasReset = false
            
            if isTimeLimitEnabled {
                logger.info("startTimer: time limit enabled")
                // For countdown mode, initialize remaining time if it's zero
                if remainingTime == 0 {
                    remainingTime = TimeInterval(timeLimitMinutes * 60)
                }
                // Calculate how much time has already elapsed
                let elapsed = TimeInterval(timeLimitMinutes * 60) - remainingTime
                startTime = Date().addingTimeInterval(-elapsed)
            } else {
                startTime = Date().addingTimeInterval(-elapsedTime)
                logger.info("startTimer: Open ended medidation")
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)

        }
    }
    
    
    func pauseTimer() {
        logger.info("pauseTimer: stopping background audio")
        self.audioService.stopBackgroundAudio()
        logger.info("pauseTimer: pausing timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = false
        
        DispatchQueue.main.async {
            self.sessionManager.stopSession()
            self.haptics.playStop()
        }
    }
    
    func stopTimer() {
        logger.info("stopTimer: stopping background audio")
        self.audioService.stopBackgroundAudio()
        logger.info("stopTimer: stopping timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = true
        
        // Disable watch screen always on
        DispatchQueue.main.async {
            self.sessionManager.stopSession()
            self.haptics.playStop()
        }
        
    }
    
    func resetTimer() {
        logger.info("resetTimer: stopping background audio")
        logger.info("resetTimer: resetting timer")
        elapsedTime = 0
        remainingTime = isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : 0
        wasReset = true
        isRunning = false
        lastChimeMinute = 0
        wasStopped = false
        
        DispatchQueue.main.async {
            self.sessionManager.stopSession()
            self.haptics.playStop()
        }
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
                    logger.info("updateTimer: playing chime at \(self.chimeIntervalMinutes)")
                    DispatchQueue.main.async {
                        self.audioService.playSound(identifier: "chime")
                    }
                    if isVibrationEnabled {
                        DispatchQueue.main.async{
                            self.haptics.playCustomPattern(intensity: 1.0, sharpness: 0.7)
                        }
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
                    logger.info("updateTimer: end of session")
                    if isSoundsEnabled {
                        logger.info("endOfSession: play finish sound")
                        DispatchQueue.main.async {
                            self.audioService.playSound(identifier: "session-end")
                        }
                    if isVibrationEnabled {
                        logger.info( "endOfSession: play success haptics")
                            DispatchQueue.main.async {
                            self.haptics.playSuccess()
                        }
                        }
                    }
                    
                    return
                }
            }
        }
}
