// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Timer Tab
            WatchTimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }.navigationTitle("Less Timer")
            
            // Settings Tab
            WatchSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
