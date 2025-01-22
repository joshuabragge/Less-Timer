import Foundation
import UIKit
import AudioToolbox

protocol HapticServiceProtocol {
    func vibrate()
    func playHapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    func playNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType)
}

class HapticService: HapticServiceProtocol {
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    func vibrate() {
        // This uses the classic vibration pattern
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func playHapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }
}
