import SwiftUI


struct ContentView: View {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
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
                        .navigationTitle("Less Timer")
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

#Preview {
    AppStorePreview(
        title: "Mindful Meditation",
        subtitle: "Track your meditation time effortlessly"
    ) {
        ContentView()  // Your existing view
    }
}


#Preview {
    AppStorePreview(
        title: "Customize Your Practice",
        subtitle: "Personalize sounds and intervals"
    ) {
        NavigationView {
            SettingsView()
        }
    }
}
