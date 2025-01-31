import SwiftUI
import OSLog

#if os(watchOS)
@MainActor
class SessionManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    private let logger = Logger.session
    
    @Published private(set) var isSessionActive = false
    @Published private(set) var startTime: Date?
    private var extendedSession: WKExtendedRuntimeSession?
    
    func startSession() {
        guard !isSessionActive else { return }
        
        extendedSession = WKExtendedRuntimeSession()
        extendedSession?.delegate = self
        extendedSession?.start()
        
        isSessionActive = true
        startTime = Date()
        logger.info("Session started")
    }
    
    func stopSession() {
        extendedSession?.invalidate()
        extendedSession = nil
        isSessionActive = false
        startTime = nil
        logger.info("Session stopped")
    }
    
    // MARK: - WKExtendedRuntimeSessionDelegate
    
    nonisolated func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        Task { @MainActor in
            logger.info("Extended runtime session started")
        }
    }
    
    nonisolated func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        Task { @MainActor in
            logger.info("Extended runtime session will expire")
        }
    }
    
    nonisolated func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                               didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                               error: Error?) {
        Task { @MainActor in
            isSessionActive = false
            startTime = nil
            logger.error("Session invalidated: \(reason.rawValue), error: \(String(describing: error))")
        }
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
