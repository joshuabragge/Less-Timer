import SwiftUI

class MeditationTracker: ObservableObject {
    @Published var isSaving = false
    @Published var saveSuccess: Bool?
    
    private let healthKitService: HealthKitServiceProtocol
    
    init(healthKitService: HealthKitServiceProtocol = HealthKitService()) {
        self.healthKitService = healthKitService
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        healthKitService.requestAuthorization { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error)")
            }
        }
    }
    
    func saveMeditationSession(duration: TimeInterval) {
        guard duration > 0 else { return }
        
        isSaving = true
        saveSuccess = nil
        
        let session = MeditationSession(
            duration: duration,
            date: Date()
        )
        
        healthKitService.saveMeditationSession(session) { success, error in
            self.isSaving = false
            self.saveSuccess = success
            
            if let error = error {
                print("Error saving meditation: \(error)")
            }
            
            // Reset success status after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.saveSuccess = nil
            }
        }
    }
}
