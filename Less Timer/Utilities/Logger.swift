import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logger for timer-related events
    static let timer = Logger(subsystem: subsystem, category: "timer")
    
    /// Logger for meditation tracking
    static let meditation = Logger(subsystem: subsystem, category: "meditation")
    
    /// Logger for health kit operations
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    
    /// Logger for audio operations
    static let audio = Logger(subsystem: subsystem, category: "audio")
    
    /// Logger for settings changes
    static let settings = Logger(subsystem: subsystem, category: "settings")
}
