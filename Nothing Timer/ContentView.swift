import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TimerView()
                //.navigationTitle("Nothing Timer")
                //.navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark) // Force dark mode
        }
        .background(Color.black) // Set navigation view background
    }
}


#Preview {
    ContentView()
}
