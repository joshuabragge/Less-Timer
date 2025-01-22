import AVFoundation

protocol AudioServiceProtocol {
    func setupAudioSession()
    func loadSound(named name: String, withExtension ext: String)
    func playSound()
}

class AudioService: AudioServiceProtocol {
    private var audioPlayer: AVAudioPlayer?
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, // Changed from .playback to .ambient for faster response
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func loadSound(named name: String, withExtension ext: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file not found: \(name).\(ext)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay() // Preload the sound
            // Create a few more instances for rapid playback
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.volume = 1.0
        } catch {
            print("Failed to load sound: \(error)")
        }
    }
    
    func playSound() {
        // Stop any current playback immediately
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
}
