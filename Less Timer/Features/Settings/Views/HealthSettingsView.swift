import SwiftUI
import HealthKit

struct HealthSettingsView: View {
    @StateObject private var healthKitService = HealthKitService()
    
    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mindfulness Minutes")
                            .font(.body)
                        Text("Save sessions to Apple Health")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
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
                        Button("Open Health App") {
                            if let url = URL(string: "x-apple-health://"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    @unknown default:
                        Text("Unknown")
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text("Apple Health")
            }
        }
        .navigationTitle("Health Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await healthKitService.checkAuthorizationStatus()
        }
    }
}

#Preview {
    NavigationView {
        HealthSettingsView()
    }
}
