import SwiftUI


struct ContentView: View {
    init() {
        // Set color for both inline and large title modes
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.gray]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.gray]
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
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.gray)
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
