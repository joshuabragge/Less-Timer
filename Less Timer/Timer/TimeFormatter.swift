import Foundation

struct TimeFormatter {
    static func components(from timeInterval: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return (hours, minutes, seconds)
    }
    
    static func formatComponent(_ value: Int, unit: String) -> String {
        if value == 1 {
            return "\(value) \(unit)"
        } else {
            return "\(value) \(unit)s"
        }
    }
}
