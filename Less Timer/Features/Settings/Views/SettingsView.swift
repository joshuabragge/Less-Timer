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
    

    private let presetChimeInterval = [1, 2, 3, 5, 10, 15]
    @State private var temporaryCustomChimeInterval = 20
    @State private var isCustomChimeIntervalSelected = false
    
    private let presetTimeLimits = [1, 2, 3, 5, 10, 15]
    @State private var temporaryCustomTimeLimit = 20
    @State private var isCustomTimeLimitSelected = false


    init() {
        updateNavigationBarAppearance()
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
                Picker("Duration", selection: Binding(
                    get: { presetTimeLimits.contains(timeLimitMinutes) ? timeLimitMinutes : -1 },
                    set: { newValue in
                        if newValue == -1 {
                            isCustomTimeLimitSelected = true
                        } else {
                            timeLimitMinutes = newValue
                        }
                    }
                )) {
                    ForEach(presetTimeLimits, id: \.self) { duration in
                        Text("\(duration)m").tag(duration)
                    }
                    Text("…").tag(-1)
                }
                .pickerStyle(.segmented)
                .disabled(!isTimeLimitEnabled)
                .sheet(isPresented: $isCustomTimeLimitSelected, onDismiss: {
                    timeLimitMinutes = temporaryCustomTimeLimit
                }) {
                    NavigationView {
                        Picker("Minutes", selection: $temporaryCustomTimeLimit) {
                            ForEach(1...180, id: \.self) { minute in
                                Text("\(minute) minutes").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .navigationTitle("Choose Duration")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    isCustomTimeLimitSelected = false
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                    .presentationDetents([.height(300)])
                }
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
                
                Picker("Chime Interval", selection: Binding(
                    get: { presetChimeInterval.contains(chimeIntervalMinutes) ? chimeIntervalMinutes : -1 },
                    set: { newValue in
                        if newValue == -1 {
                            isCustomChimeIntervalSelected = true
                        } else {
                            chimeIntervalMinutes = newValue
                        }
                    }
                )) {
                    ForEach(presetChimeInterval, id: \.self) { duration in
                        Text("\(duration)m").tag(duration)
                    }
                    Text("…").tag(-1)
                }
                .pickerStyle(.segmented)
                .disabled(!isRecurringChimeEnabled)
                .sheet(isPresented: $isCustomChimeIntervalSelected, onDismiss: {
                    chimeIntervalMinutes = temporaryCustomChimeInterval
                }) {
                    NavigationView {
                        Picker("Minutes", selection: $temporaryCustomChimeInterval) {
                            ForEach(1...180, id: \.self) { minute in
                                Text("\(minute) minutes").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .navigationTitle("Choose Chime Inverval")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    isCustomChimeIntervalSelected = false
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                    .presentationDetents([.height(300)])
                }
                
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
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    #endif
                }
            }
        }
        .navigationTitle("Settings")
        //.toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
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
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
