import SwiftUI
import OSLog

#if os(watchOS)
@MainActor
class SessionManager: ObservableObject {
    private let logger = Logger.session
    
    @Published private(set) var isSessionActive = false
    @Published private(set) var startTime: Date?
    
    init() {}
    
    func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
        startTime = Date()
        logger.info("startSession")
    }
    
    func stopSession() {
        isSessionActive = false
        startTime = nil
        logger.info( "stopSession")
    }
}

#else
@MainActor
class SessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionActive = false
    @Published private(set) var startTime: Date?
    
    private let logger = Logger.session
    
    func startSession() {
        logger.info("startSession: SessionManager not supported on this platform")
    }
    func stopSession() {
        logger.info("startSession: SessionManager not supported on this platform")
    }
}
#endif
