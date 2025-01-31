import SwiftUI
import HealthKit

struct SettingsView: View {
    
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
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(!isTimeLimitEnabled)
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
                        Text("2 min").tag(2)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                    }
                    .pickerStyle(.menu)
                    .disabled(!isRecurringChimeEnabled)
                
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
                    Text("Version")
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
                    }
                    Spacer()
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Settings")
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
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
