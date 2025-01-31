import SwiftUI
#if os(watchOS)

class ExtendedRuntimeSessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionActive = false
    private var session: Any? // We'll cast this to the proper type at runtime
    
    func startSession() {
        if let ExtendedRuntimeSession = NSClassFromString("WKExtendedRuntimeSession") as? NSObject.Type {
            let newSession = ExtendedRuntimeSession.init()
            // Set up delegate and start session using selector calls
            if newSession.responds(to: Selector(("setDelegate:"))) {
                newSession.perform(Selector(("setDelegate:")), with: self)
            }
            if newSession.responds(to: Selector(("start"))) {
                newSession.perform(Selector(("start")))
            }
            session = newSession
        }
    }
    
    func stopSession() {
        if let currentSession = session as? NSObject {
            if currentSession.responds(to: Selector(("invalidate"))) {
                currentSession.perform(Selector(("invalidate")))
            }
        }
        session = nil
        isSessionActive = false
    }
}

@objc protocol ExtendedRuntimeSessionDelegate: NSObjectProtocol {
    @objc optional func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: NSObject)
    @objc optional func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: NSObject)
    @objc optional func extendedRuntimeSession(_ extendedRuntimeSession: NSObject,
                                             didInvalidateWith reason: Int,
                                             error: Error?)
}

extension ExtendedRuntimeSessionManager: ExtendedRuntimeSessionDelegate {
    @objc func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: NSObject) {
        DispatchQueue.main.async { [weak self] in
            self?.isSessionActive = true
        }
    }
    
    @objc func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: NSObject) {
        DispatchQueue.main.async { [weak self] in
            self?.isSessionActive = false
        }
    }
    
    @objc func extendedRuntimeSession(_ extendedRuntimeSession: NSObject,
                                     didInvalidateWith reason: Int,
                                     error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isSessionActive = false
            self?.session = nil
        }
    }
}

#else
class ExtendedRuntimeSessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionActive = false
    
    func startSession() {}
    func stopSession() {}
}
#endif
