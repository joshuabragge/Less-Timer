import SwiftUI

struct ContentView: View {
    init() {
        // Set color for both inline and large title modes
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.gray]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.gray]
    }

    
    var body: some View {
        NavigationView {
            TimerView()
                .background(Color.black)
                .navigationTitle("Less Timer")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .bold(true)
                        }
                    }
                }
        }

        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
