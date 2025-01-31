import SwiftUI
#if os(watchOS)

@available(watchOS 7.0, *)
class ExtendedRuntimeSessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionActive = false
    private var session: WKExtendedRuntimeSession?
    
    func startSession() {
        guard session == nil || session?.state != .running else { return }
        session = WKExtendedRuntimeSession()
        session?.start()
    }
    
    func stopSession() {
        session?.invalidate()
        session = nil
        isSessionActive = false
    }
}

#else
class ExtendedRuntimeSessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionActive = false
    
    func startSession() {}
    func stopSession() {}
}
#endif
