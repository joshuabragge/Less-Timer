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
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var wasStopped = false
    @Published var wasReset = true
    
    /// Keep screen on for watch
    @MainActor private let sessionManager = SessionManager()
    private var meditationTracker: MeditationTracker = MeditationTracker()
    
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
            Task { @MainActor in
                sessionManager.startSession()
            }
            
            logger.info("startTimer: starting background audio")
            audioService.startBackgroundAudio()
            logger.info("startTimer: starting timer")
            //play sound on reset if enabled
            if isSoundsEnabled && wasReset {
                logger.info("startTimer: play starting sound")
                Task { @MainActor in
                    audioService.playSound(identifier: "session-end")
                }
            }

            logger.info("startTimer: playing start vibration")
            Task { @MainActor in
                haptics.playStart()
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
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.33, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            RunLoop.current.add(timer!, forMode: .common)

        }
    }
    
    
    func pauseTimer() {
        logger.info("pauseTimer: stopping background audio")
        audioService.stopBackgroundAudio()
        logger.info("pauseTimer: pausing timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = false
        
        Task { @MainActor in
            haptics.playStop()
            try? await Task.sleep(for: .seconds(0.5))
            sessionManager.stopSession()
        }
    }
    
    func stopTimer() {
        logger.info("stopTimer: stopping background audio")
        audioService.stopBackgroundAudio()
        logger.info("stopTimer: stopping timer")
        isRunning = false
        timer?.invalidate()
        timer = nil
        wasStopped = true
        
        Task { @MainActor in
            haptics.playStop()
            try? await Task.sleep(for: .seconds(0.5))
            sessionManager.stopSession()
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
        
        Task { @MainActor in
            haptics.playSuccess()
            try? await Task.sleep(for: .seconds(0.5))
            sessionManager.stopSession()
        }
    }
    
    private func handleTimerCompletion(finalDuration: TimeInterval) {
            logger.info("handleTimerCompletion: beginning end of session sequence")
            
            // Stop the timer but don't stop the session yet
            isRunning = false
            timer?.invalidate()
            timer = nil
            wasStopped = true
            
            // Update state variables
            elapsedTime = finalDuration
            remainingTime = isTimeLimitEnabled ? TimeInterval(timeLimitMinutes * 60) : 0
            wasReset = true
            lastChimeMinute = 0
            
            Task { @MainActor in
                if isSoundsEnabled {
                    logger.info("handleTimerCompletion: playing finish sound")
                    audioService.playSound(identifier: "session-end")
                }
                
                if isVibrationEnabled {
                    logger.info("handleTimerCompletion: playing triple success haptics")
                    haptics.playSuccess()
                    try? await Task.sleep(for: .seconds(0.5))
                    haptics.playSuccess()
                    try? await Task.sleep(for: .seconds(0.5))
                    haptics.playSuccess()
                    try? await Task.sleep(for: .seconds(0.5))
                }
                
                logger.info("handleTimerCompletion: saving meditation session")
                meditationTracker.saveMeditationSession(duration: finalDuration)
                
                logger.info("handleTimerCompletion: ending watch session")
                sessionManager.stopSession()
                
                logger.info("handleTimerCompletion: end of session sequence complete")
            }
        }
        
        private func updateTimer() {
            guard let startTime = startTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            elapsedTime = elapsed
            
            if isTimeLimitEnabled {
                remainingTime = max(TimeInterval(timeLimitMinutes * 60) - elapsed, 0)
                
                // Check if timer has reached zero
                if remainingTime == 0 {
                    let finalDuration = self.elapsedTime // Store duration
                    logger.info("updateTimer: time limit reached, handling session completion")
                    
                    handleTimerCompletion(finalDuration: finalDuration)
                    
                    logger.info("updateTimer: stopping background audio")
                    audioService.stopBackgroundAudio()
                                     
                    return
                }
            }
            
            if isRecurringChimeEnabled && (!isTimeLimitEnabled || remainingTime > 1.0) {
                let currentMinute = Int(elapsedTime / 60)
                if currentMinute >= (lastChimeMinute + chimeIntervalMinutes) {
                    logger.info("updateTimer: playing chime at \(self.chimeIntervalMinutes)")
                    if isSoundsEnabled {
                        Task { @MainActor in
                            audioService.playSound(identifier: "chime")
                        }
                    }
                    if isVibrationEnabled {
                        Task { @MainActor in
                            haptics.playSuccess()
                        }
                    }
                    lastChimeMinute = currentMinute
                }
            }
        }
}
