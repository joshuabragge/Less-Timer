// WatchSettingsView.swift
import SwiftUI
import HealthKit

struct WatchSettingsView: View {
    @AppStorage("isStartSoundEnabled") private var isStartSoundEnabled = true
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 1
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    @StateObject private var healthKitService = HealthKitService()
    
    init() {
        print("Current value:", UserDefaults.standard.integer(forKey: "chimeIntervalMinutes"))
    }
    
    var body: some View {
        List {
            Section(header: Text("Meditation Settings")) {
                Toggle("Time Limit", isOn: $isTimeLimitEnabled)
                if isTimeLimitEnabled {
                    Picker("Time Limit", selection: $timeLimitMinutes) {
                        Text("1 min").tag(1)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                    }
                }
                Toggle("Recurring Chime", isOn: $isRecurringChimeEnabled)
                if isRecurringChimeEnabled {
                    Picker("Chime Interval", selection: $chimeIntervalMinutes) {
                        Text("1 min").tag(1)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                    }
                }
                Toggle("Starting Sound", isOn: $isStartSoundEnabled)
                #if DEBUG
                Button("Debug") {
                    print("chimeIntervalMinutes:", UserDefaults.standard.integer(forKey: "chimeIntervalMinutes"))
                    print("isTimeLimitEnabled:", UserDefaults.standard.bool(forKey: "isTimeLimitEnabled"))
                    print("timeLimitMinutes:", UserDefaults.standard.integer(forKey: "timeLimitMinutes"))
                    
                }
                #endif
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
            }
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.gray)
                }
            }
        }
        .task {
            await healthKitService.checkAuthorizationStatus()
        }
    }
}
#Preview {
    WatchSettingsView()
}
