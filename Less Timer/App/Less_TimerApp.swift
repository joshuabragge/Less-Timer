import SwiftUI

@main

struct Less_TimerApp: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            "chimeIntervalMinutes": 1,
            "isSoundsEnabled": false,
            "isRecurringChimeEnabled": true,
            "isTimeLimitEnabled": false,
            "timeLimitMinutes": 5,
            "isVibrationEnabled": false
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
