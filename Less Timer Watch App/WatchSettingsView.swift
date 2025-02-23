// WatchSettingsView.swift
import SwiftUI
import HealthKit

struct WatchSettingsView: View {
    
    
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = true
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    @AppStorage("isSoundsEnabled") private var isSoundsEnabled = false
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 1
    
    @AppStorage("isVibrationEnabled") private var isVibrationEnabled = true
    
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
                    if !isTimeLimitEnabled {
                        Text("Off").tag(0)
                    } else {
                        Text("1 min").tag(1)
                        Text("2 min").tag(2)
                        Text("3 min").tag(3)
                        Text("4 min").tag(4)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("20 min").tag(20)
                        Text("30 min").tag(30)
                    }
                }.disabled(!isTimeLimitEnabled)
            }
            Section(header: Text("Sounds and Haptics")) {
                Toggle("Sounds", isOn: $isSoundsEnabled)
                Toggle("Vibrations", isOn: $isVibrationEnabled)

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
                    if !isRecurringChimeEnabled {
                        Text("Off").tag(0)
                    } else {
                        Text("1 min").tag(1)
                        Text("2 min").tag(2)
                        Text("3 min").tag(3)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                    }
                }.disabled(!isRecurringChimeEnabled)
                
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
                        .foregroundColor(.white)
                }
                #if DEBUG
                //Button("Debug") {
                  //  print("isSoundsEnabled:", UserDefaults.standard.integer(forKey: "isSoundsEnabled"))
                   // print("chimeIntervalMinutes:", UserDefaults.standard.integer(forKey: "chimeIntervalMinutes"))
                   // print("isTimeLimitEnabled:", UserDefaults.standard.bool(forKey: "isTimeLimitEnabled"))
                   // print("timeLimitMinutes:", UserDefaults.standard.integer(forKey: "timeLimitMinutes"))
                //}
                #endif
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
