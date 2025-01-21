import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TimerView()
                //.navigationTitle("Nothing Timer")
                //.navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
                .ignoresSafeArea(.container, edges: .top) // Only ignore safe area at the top
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
        }
        .background(Color.black) // Set navigation view background
    }
}


#Preview {
    ContentView()
}
