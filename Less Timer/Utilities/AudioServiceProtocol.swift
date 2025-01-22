import AVFoundation

protocol AudioServiceProtocol {
    func setupAudioSession()
    func loadSound(named name: String, withExtension ext: String, identifier: String)
    func playSound(identifier: String)
}

class AudioService: AudioServiceProtocol {
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]

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
        player.stop()
        player.currentTime = 0
        player.play()
    }
}
