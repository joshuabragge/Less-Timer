// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isStartSoundEnabled") private var isStartSoundEnabled = true
    // Chime settings
    @AppStorage("isRecurringChimeEnabled") private var isRecurringChimeEnabled = true
    @AppStorage("chimeIntervalMinutes") private var chimeIntervalMinutes = 5
    
    // Time limit settings
    @AppStorage("isTimeLimitEnabled") private var isTimeLimitEnabled = false
    @AppStorage("timeLimitMinutes") private var timeLimitMinutes = 10
    
    // State for custom input sheets
    @State private var showingCustomChimeSheet = false
    @State private var showingCustomTimeLimitSheet = false
    
    // Computed properties for picker selections
    private var selectedChimePreset: Binding<Int> {
            Binding(
                get: {
                    let interval = UserDefaults.standard.integer(forKey: "chimeIntervalMinutes")
                    return TimerPreset.preset(for: interval).rawValue
                },
                set: { newValue in
                    if newValue == TimerPreset.custom.rawValue {
                        showingCustomChimeSheet = true
                    } else {
                        // Save the selected preset value directly to storage
                        chimeIntervalMinutes = newValue
                        UserDefaults.standard.set(newValue, forKey: "chimeIntervalMinutes")
                        print("Saved chimeIntervalMinutes: \(newValue)")
                    }
                }
            )
        }
    
    private var selectedTimeLimitPreset: Binding<Int> {
        Binding(
            get: {
                let limit = UserDefaults.standard.integer(forKey: "timeLimitMinutes")
                return TimerPreset.preset(for: limit).rawValue
            },
            set: { newValue in
                if newValue == TimerPreset.custom.rawValue {
                    showingCustomTimeLimitSheet = true
                } else {
                    timeLimitMinutes = newValue
                    UserDefaults.standard.set(newValue, forKey: "timeLimitMinutes")
                    print("Saved timeLimitMinutes: \(newValue)")
                }
            }
        )
    }
    
    var body: some View {
        List {
            Section(header: Text("Sounds")) {
                Toggle("Starting Sound", isOn: Binding(
                    get: { isStartSoundEnabled },
                    set: { newValue in
                        isStartSoundEnabled = newValue
                        UserDefaults.standard.set(isStartSoundEnabled, forKey: "isStartSoundEnabled")
                        print("Saved Starting Sound: \(newValue)")
                    }
                    ))
                Toggle("Recurring Chime", isOn: Binding(
                    get: { isRecurringChimeEnabled },
                    set: { newValue in
                        isRecurringChimeEnabled = newValue
                        UserDefaults.standard.set(newValue, forKey: "isRecurringChimeEnabled")
                        print("Saved Recurring Chime: \(newValue)")

                    }
                ))
                
                if isRecurringChimeEnabled {
                    Picker("Chime Interval", selection: selectedChimePreset) {
                        ForEach(TimerPreset.allCases, id: \.rawValue) { preset in
                            Text(preset == .custom ? "Custom..." : TimerPreset.displayText(for: preset.rawValue))
                                .tag(preset.rawValue)
                        }
                    }
                    
                    if TimerPreset.preset(for: chimeIntervalMinutes) == .custom {
                        Text("\(chimeIntervalMinutes) Minutes")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Meditation Style")) {
                Toggle("Time Limit", isOn: $isTimeLimitEnabled)
                
                if isTimeLimitEnabled {
                    Picker("Duration", selection: selectedTimeLimitPreset) {
                        ForEach(TimerPreset.allCases, id: \.rawValue) { preset in
                            Text(preset == .custom ? "Custom..." : TimerPreset.displayText(for: preset.rawValue))
                                .tag(preset.rawValue)
                        }
                    }
                    
                    if TimerPreset.preset(for: timeLimitMinutes) == .custom {
                        Text("\(timeLimitMinutes) Minutes")
                            .foregroundColor(.gray)
                    }
                }
            }
            Section(header: Text("Health")) {
                NavigationLink(destination: HealthSettingsView()) {
                    Label("Apple Health", systemImage: "heart.fill")
                }
            }
            Section(header: Text("Support Our Community!")) {
                HStack {
                    Link("Little Bee Gallery", destination: URL(string: "https://www.littlebeegallery.com/")!)

                    Spacer()
                        .foregroundColor(.gray)
                }
                HStack {
                    Link("Calgary Food Bank", destination: URL(string: "https://www.calgaryfoodbank.com/")!)

                    Spacer()
                        .foregroundColor(.gray)
                }
                HStack {
                    Link("Trees Canada", destination: URL(string: "https://treecanada.ca/")!)

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
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingCustomChimeSheet) {
            CustomDurationPicker(
                title: "Custom Chime Interval",
                minutes: $chimeIntervalMinutes
            )
        }
        .sheet(isPresented: $showingCustomTimeLimitSheet) {
            CustomDurationPicker(
                title: "Custom Time Limit",
                minutes: $timeLimitMinutes
            )
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
