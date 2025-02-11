import SwiftUI

@main
struct Less_Timer_Watch_Watch_App: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            "chimeIntervalMinutes": 1,
            "isSoundsEnabled": false,
            "isRecurringChimeEnabled": true,
            "isTimeLimitEnabled": true,
            "timeLimitMinutes": 5,
            "isVibrationEnabled": true
        ])
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
