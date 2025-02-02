import SwiftUI

struct AppStoreScreenshots: View {
    var body: some View {
        TabView {
            // Screenshot 1: Main Timer
            AppStorePreview(
                title: "Less is More",
                subtitle: "Simple, distraction-free meditation timer"
            ) {
                ContentView()
            }
            
            // Screenshot 2: Settings
            AppStorePreview(
                title: "Your Practice, Your Way",
                subtitle: "Customize sounds, intervals, and more"
            ) {
                NavigationView {
                    SettingsView()
                }
            }
            
            // Screenshot 3: Health Integration
            AppStorePreview(
                title: "Track Your Progress",
                subtitle: "Seamless Apple Health integration"
            ) {
                NavigationView {
                    SettingsView()
                }
            }
        }
        
    }
}

// Preview for quickly viewing all screenshots
#Preview {
    AppStoreScreenshots()
}
