// TimerPresets.swift
import Foundation

enum TimerPreset: Int, CaseIterable {
    case oneMinute = 1
    case fiveMinutes = 5
    case tenMinutes = 10
    case custom = -1  // Using -1 to represent custom
    
    var id: Int { self.rawValue }
    
    static func displayText(for minutes: Int) -> String {
        if let preset = TimerPreset(rawValue: minutes) {
            switch preset {
            case .oneMinute: return "1 Minute"
            case .fiveMinutes: return "5 Minutes"
            case .tenMinutes: return "10 Minutes"
            case .custom: return "Custom"
            }
        }
        return "\(minutes) Minutes"
    }
    
    static func preset(for minutes: Int) -> TimerPreset {
        TimerPreset(rawValue: minutes) ?? .custom
    }
}
