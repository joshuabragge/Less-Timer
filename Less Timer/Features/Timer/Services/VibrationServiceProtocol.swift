import Foundation

#if canImport(CoreHaptics)
import CoreHaptics
#endif

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

/// Handles haptic feedback across iOS and watchOS platforms
protocol HapticServiceProtocol {
    func playTap()
    func playSuccess()
    func playError()
    func playStart()
    func playStop()
    func playCustomPattern(intensity: Float, sharpness: Float)
}

final class HapticManager: HapticServiceProtocol {
    // MARK: - Properties
    
    /// Shared instance for singleton access
    static let shared = HapticManager()
    
    #if canImport(CoreHaptics)
    /// CoreHaptics engine for custom patterns (iOS only)
    private var engine: CHHapticEngine?
    #endif
    
    // MARK: - Initialization
    
    init() {
        #if canImport(CoreHaptics)
        setupHapticEngine()
        #endif
    }
    
    // MARK: - Setup
    
    #if canImport(CoreHaptics)
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Automatically restart the engine if it stops
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            // Restart the engine if app comes back from background
            engine?.stoppedHandler = { [weak self] reason in
                guard let self = self else { return }
                try? self.engine?.start()
            }
        } catch {
            print("Haptic engine setup failed: \(error.localizedDescription)")
        }
    }
    #endif
    
    // MARK: - Haptic Patterns
    
    /// Plays a single tap haptic feedback
    func playTap() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
    
    /// Plays a success haptic feedback
    func playSuccess() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
    
    /// Plays an error haptic feedback
    func playError() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #endif
    }
    
    /// Plays a warning haptic feedback
    func playStart() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred(intensity: 0.5)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.start)
        #endif
    }
    
    func playStop() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred(intensity: 0.5)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.stop)
        #endif
    }
    /// Plays a custom pattern (iOS and watchOS)
    /// - Parameter intensity: Intensity of the haptic feedback (0.0 to 1.0)
    /// - Parameter sharpness: Sharpness of the haptic feedback (0.0 to 1.0)
    func playCustomPattern(intensity: Float = 1.0, sharpness: Float = 1.0) {
        #if os(iOS) && canImport(CoreHaptics)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                             value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                             value: sharpness)
        
        let event = CHHapticEvent(eventType: .hapticTransient,
                                parameters: [intensity, sharpness],
                                relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
        #elseif os(watchOS)
        // Double tap pattern for more noticeable feedback
        WKInterfaceDevice.current().play(.notification)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            WKInterfaceDevice.current().play(.notification)
        }
        #endif
    }
}

// MARK: - Usage Example

struct HapticExample {
    func demonstrateHaptics() {
        // Basic haptics
        HapticManager.shared.playTap()
        HapticManager.shared.playSuccess()
        HapticManager.shared.playError()
        HapticManager.shared.playStart()
        
        // Custom pattern (iOS only)
        HapticManager.shared.playCustomPattern(intensity: 0.8, sharpness: 0.5)
    }
}
