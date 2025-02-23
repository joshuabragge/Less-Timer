import SwiftUI

struct ContentView: View {
    init(haptics: HapticServiceProtocol = HapticManager.shared) {
        self.haptics = haptics
        updateNavigationBarAppearance()
    }
    
    @State private var showIcon = true
    @State private var firstLaunch = true
    @Environment(\.colorScheme) var colorScheme
    private let haptics: HapticServiceProtocol
    
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
            .preferredColorScheme(.dark)
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
                                        .simultaneousGesture(TapGesture().onEnded {
                                            self.haptics.playTap()
                                        })
                                }
                            }
                        }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(.dark)
            .onAppear {
                updateNavigationBarAppearance()
             }
             .onChange(of: colorScheme) { oldValue, newValue in
                 updateNavigationBarAppearance()
             }
        }
    }
    
    private func updateNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        let titleColor = colorScheme == .dark ? UIColor.white : UIColor.black
        
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.buttonAppearance = backButtonAppearance
        appearance.backButtonAppearance = backButtonAppearance
        
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(titleColor, renderingMode: .alwaysOriginal)
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)

        UINavigationBar.appearance().tintColor = titleColor
        UINavigationBar.appearance().standardAppearance = appearance

    }
}

#Preview {
    ContentView()
}

