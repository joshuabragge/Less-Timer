import SwiftUI


struct ContentView: View {
    init() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            // This is crucial for the back button color
            appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().tintColor = .white
            
            // Apply the appearance to all navigation bars
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    
    @State private var showIcon = true
    @State private var firstLaunch = true
    
    var body: some View {
        if showIcon && firstLaunch {
            ZStack() {
                Color.black
                .ignoresSafeArea()

                Spacer()
                Image("less-timer-icon-clear.png")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .opacity(showIcon ? 1 : 0)
                    .transition(.opacity)
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.easeOut(duration: 1)) {
                        showIcon = false
                        firstLaunch = false
                    }
                }
                
            }
        }

        else {
            NavigationView {
                ZStack {
                    Color.black
                    .ignoresSafeArea()
                    
                    TimerView()
                        .navigationTitle("Less Timer").foregroundColor(.white)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.white)
                                        .bold(true)
                                }
                            }
                        }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    ContentView()
}
