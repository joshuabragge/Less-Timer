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
                .navigationTitle("Nothing Timer")
                //.navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
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
        .background(Color.black)
        .statusBar(hidden: true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
