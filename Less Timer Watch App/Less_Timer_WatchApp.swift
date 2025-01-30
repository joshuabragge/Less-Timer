import SwiftUI

@main
struct Less_Timer_Watch_Watch_App: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            "chimeIntervalMinutes": 1,
            "isStartSoundEnabled": true,
            "isRecurringChimeEnabled": true,
            "isTimeLimitEnabled": false,
            "timeLimitMinutes": 5
        ])
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
