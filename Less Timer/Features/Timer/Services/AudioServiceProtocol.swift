import AVFoundation

protocol AudioServiceProtocol {
    func setupAudioSession()
    func loadSound(named name: String, withExtension ext: String, identifier: String)
    func playSound(identifier: String)
    func startBackgroundAudio()
    func stopBackgroundAudio()

}

class AudioService: AudioServiceProtocol {
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundPlayer: AVAudioPlayer?
    
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers, .interruptSpokenAudioAndMixWithOthers]
                
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func loadSound(named name: String, withExtension ext: String, identifier: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file not found: \(name).\(ext)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            player.numberOfLoops = 0
            player.volume = 1.0
            audioPlayers[identifier] = player
        } catch {
            print("Failed to load sound: \(error)")
        }
    }
    
    func playSound(identifier: String) {
        guard let player = audioPlayers[identifier] else {
            print("No sound loaded for identifier: \(identifier)")
            return
        }
        backgroundPlayer?.pause()
        
        player.stop()
        player.currentTime = 0
        player.play()
        
        // Resume background audio after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.backgroundPlayer?.play()
        }
    }
    
    func startBackgroundAudio() {
        // Load and play background silent audio if not already loaded
        if backgroundPlayer == nil {
            guard let silentURL = Bundle.main.url(forResource: "silent-background", withExtension: "mp3") else {
                print("Background audio file not found")
                return
            }
            
            do {
                backgroundPlayer = try AVAudioPlayer(contentsOf: silentURL)
                backgroundPlayer?.numberOfLoops = -1  // Infinite loop
                backgroundPlayer?.volume = 0.01       // Very low volume
                backgroundPlayer?.prepareToPlay()
            } catch {
                print("Failed to load background audio: \(error)")
            }
        }
        
        backgroundPlayer?.play()
    }
    
    func stopBackgroundAudio() {
        backgroundPlayer?.stop()
    }
}

