import Foundation
import HealthKit

protocol HealthKitServiceProtocol: ObservableObject {
    var authorizationStatus: HKAuthorizationStatus { get }
    func checkAuthorizationStatus() async
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    func saveMeditationSession(_ session: MeditationSession, completion: @escaping (Bool, Error?) -> Void)
}

#if true
class HealthKitService: ObservableObject, HealthKitServiceProtocol {
    private let healthStore = HKHealthStore()
    private let meditationType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    
    @Published private(set) var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.authorizationStatus = .sharingDenied
            }
            return
        }
        
        let status = healthStore.authorizationStatus(for: meditationType)
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let typesToShare: Set<HKSampleType> = [meditationType]
        let typesToRead: Set<HKObjectType> = [] // Empty set - no read permissions needed
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
            Task {
                await self?.checkAuthorizationStatus()
            }
            completion(success, error)
        }
    }
    
    func saveMeditationSession(_ session: MeditationSession, completion: @escaping (Bool, Error?) -> Void) {
        // First check if we have authorization
        guard authorizationStatus == .sharingAuthorized else {
            completion(false, NSError(domain: "HealthKitService",
                                    code: 403,
                                    userInfo: [NSLocalizedDescriptionKey: "Health data access not authorized"]))
            return
        }
        
        let sample = HKCategorySample(
            type: meditationType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: session.date.addingTimeInterval(-session.duration),
            end: session.date
        )
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}

#else
// Mock implementation for testing or when HealthKit is not available
class HealthKitService: ObservableObject, HealthKitServiceProtocol {
    @Published private(set) var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    func checkAuthorizationStatus() async {
        print("🏥 [DummyHealthKit] Checking authorization status")
        // Simulate checking status
        DispatchQueue.main.async {
            self.authorizationStatus = .notDetermined
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        print("🏥 [DummyHealthKit] Authorization requested")
        // Always return success since we're just simulating
        DispatchQueue.main.async {
            self.authorizationStatus = .sharingAuthorized
            completion(true, nil)
        }
    }
    
    func saveMeditationSession(_ session: MeditationSession, completion: @escaping (Bool, Error?) -> Void) {
        print("🏥 [DummyHealthKit] Saving meditation session:")
        print("   - Duration: \(session.duration) seconds")
        print("   - Date: \(session.date)")
        
        // Simulate successful save
        DispatchQueue.main.async {
            completion(true, nil)
        }
    }
}
#endif

// Helper to get the correct implementation
extension HealthKitServiceProtocol {
    static func create() -> any HealthKitServiceProtocol {
        #if false
        return HealthKitService()
        #else
        return HealthKitService()
        #endif
    }
}
