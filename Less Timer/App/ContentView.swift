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
                Color.primaryBackground
                .ignoresSafeArea()

                Spacer()
                Image("less-timer-icon-clear.png")
                    .resizable()
                    .frame(width: 120, height: 120)
                    //.foregroundColor(.primaryFont)
                    .colorMultiply(Color.primaryFont)
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
                    Color.primaryBackground
                    .ignoresSafeArea()
                    
                    TimerView()
                        .navigationTitle("Less Timer")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.primaryFont)
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
        let titleColor = UIColor(named: "primaryFont") ?? (colorScheme == .dark ? UIColor.white : UIColor.black)
        
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryFont]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.primaryFont]
        
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

