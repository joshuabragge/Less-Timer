import SwiftUI
import HealthKit

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("isSoundsEnabled") private var isSoundsEnabled = true
    // Chime settings
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    
    // Time limit settings
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    @AppStorage("isVibrationEnabled") private var isVibrationEnabled = false
    
    @State private var showingSafariView = false
    @State private var selectedURL: URL? = nil
    
    @StateObject private var healthKitService = HealthKitService()
    
    init() {
        
}
    
    var body: some View {
        List {
            Section(header: Text("Meditation Settings")) {
                Toggle("Time Limit", isOn: Binding(
                    get: { isTimeLimitEnabled },
                    set: { newValue in
                        isTimeLimitEnabled = newValue
                        if !newValue {
                            timeLimitMinutes = 0
                        } else if timeLimitMinutes == 0 {
                            timeLimitMinutes = 10
                        }
                    }
                ))
                
                Picker("Duration", selection: $timeLimitMinutes) {
                    ForEach(1...60, id: \.self) { minute in
                        Text("\(minute) min")
                            .tag(minute)
                            .foregroundColor(colorScheme == .dark ? .white : .white)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!isTimeLimitEnabled)
                .accentColor(.white)
            }
            
            Section(header: Text("Sounds and Haptics")) {
                Toggle("Sounds", isOn: $isSoundsEnabled)
                Toggle("Vibration", isOn: $isVibrationEnabled)

                Toggle("Recurring Chime", isOn: Binding(
                    get: { isRecurringChimeEnabled },
                    set: { newValue in
                        isRecurringChimeEnabled = newValue
                        if !newValue {
                            chimeIntervalMinutes = 0  // Set to Off when disabled
                        } else if chimeIntervalMinutes == 0 {
                            chimeIntervalMinutes = 1  // Set to 1 min if it was Off
                        }
                    }
                ))
                
                Picker("Chime Interval", selection: $chimeIntervalMinutes) {
                    Text("1 min").tag(1)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("2 min").tag(2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("5 min").tag(5)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("10 min").tag(10)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("15 min").tag(15)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("20 min").tag(20)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("30 min").tag(30)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .pickerStyle(.menu)
                .disabled(!isRecurringChimeEnabled)
                .accentColor(colorScheme == .dark ? .white : .black)
            }
            
            Section(header: Text("Health")) {
                HStack {
                    Text("Apple Health")
                    Spacer()
                    switch healthKitService.authorizationStatus {
                    case .notDetermined:
                        Button("Enable") {
                            healthKitService.requestAuthorization { success, error in
                                Task {
                                    await healthKitService.checkAuthorizationStatus()
                                }
                            }
                        }
                    case .sharingAuthorized:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case .sharingDenied:
                        Text("Denied")
                            .foregroundColor(.red)
                    @unknown default:
                        Text("Unknown")
                    }
                }
               // NavigationLink(destination: HealthSettingsView()) {
                 //   Label("Apple Health", systemImage: "heart.fill")
                //}
            }
            Section(header: Text("Support Our Community!")) {
                HStack {
                    Button("Little Bee Gallery") {
                        if let url = SafariService.shared.validateURL("https://www.littlebeegallery.com/") {
                            selectedURL = url
                            showingSafariView = true
                        }
                    }.foregroundColor(.blue)
                    Spacer()
                        .foregroundColor(.gray)
                }
                HStack {
                    Button("Calgary Food Bank") {
                            if let url = SafariService.shared.validateURL("https://www.calgaryfoodbank.com/") {
                                selectedURL = url
                                showingSafariView = true
                            }
                        }.foregroundColor(.blue)
                    Spacer()
                        .foregroundColor(.gray)
                }
                HStack {
                    Button("Trees Canada") {
                            if let url = SafariService.shared.validateURL("https://treecanada.ca/") {
                                selectedURL = url
                                showingSafariView = true
                            }
                        }.foregroundColor(.blue)
                    Spacer()
                        .foregroundColor(.gray)
                }
            }
            Section(header: Text("About")) {
                HStack {
                    Text("Less Timer Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.gray)
                }
                HStack {
                    Button("Source Code") {
                        if let url = SafariService.shared.validateURL("https://github.com/joshuabragge/Less-Timer") {
                            selectedURL = url
                            showingSafariView = true
                        }
                    }.foregroundColor(.blue)
                    Spacer()
                        .foregroundColor(.gray)
                }
                HStack{
                    #if DEBUG
                    Button("Debug") {
                        print("isSoundsEnabled:", UserDefaults.standard.integer(forKey: "isSoundsEnabled"))
                        print("chimeIntervalMinutes:", UserDefaults.standard.integer(forKey: "chimeIntervalMinutes"))
                        print("isTimeLimitEnabled:", UserDefaults.standard.bool(forKey: "isTimeLimitEnabled"))
                        print("timeLimitMinutes:", UserDefaults.standard.integer(forKey: "timeLimitMinutes"))
                        
                    }
                    #endif
                }
            }
        }
        .navigationTitle("Settings")
        .toolbarColorScheme(colorScheme, for: .navigationBar) // This ensures proper color scheme
                .toolbarBackground(.clear, for: .navigationBar)
        .onAppear {
            updateNavigationBarAppearance()
         }
         .onChange(of: colorScheme) { oldValue, newValue in
             updateNavigationBarAppearance()
         }
        .fullScreenCover(isPresented: Binding(
            get: { showingSafariView && selectedURL != nil },
            set: { showingSafariView = $0 }
        )) {
            if let url = selectedURL {
                SafariView(url: url, isPresented: $showingSafariView)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    private func updateNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            
            let titleColor = colorScheme == .dark ? UIColor.white : UIColor.black
            appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
            appearance.titleTextAttributes = [.foregroundColor: titleColor]
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.standardAppearance = appearance
        }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
