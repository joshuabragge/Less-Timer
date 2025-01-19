import HealthKit

protocol HealthKitServiceProtocol {
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    func saveMeditationSession(_ session: MeditationSession, completion: @escaping (Bool, Error?) -> Void)
}

class HealthKitService: HealthKitServiceProtocol {
    private let healthStore = HKHealthStore()
    private let meditationType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let typesToShare: Set<HKSampleType> = [meditationType]
        let typesToRead: Set<HKObjectType> = [] // Empty set - no read permissions
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func saveMeditationSession(_ session: MeditationSession, completion: @escaping (Bool, Error?) -> Void) {
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
