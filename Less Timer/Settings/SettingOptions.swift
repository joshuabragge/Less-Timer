// TimerPresets.swift
import Foundation

enum TimerPreset: Int, CaseIterable {
    case oneMinute = 1
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case twentyMinutes = 20
    case thirtyMinutes = 30
    case fourtyFiveMinutes = 45
    case oneHour = 60
    case custom = -1
    
    var id: Int { self.rawValue }
    
    static func displayText(for minutes: Int) -> String {
        if let preset = TimerPreset(rawValue: minutes) {
            switch preset {
            case .oneMinute: return "1 Minute"
            case .fiveMinutes: return "5 Minutes"
            case .tenMinutes: return "10 Minutes"
            case .fifteenMinutes: return "15 Minutes"
            case .twentyMinutes: return "20 Minutes"
            case .thirtyMinutes: return "30 Minutes"
            case .fourtyFiveMinutes: return "45 Minutes"
            case .oneHour: return "1 Hour"
            case .custom: return "Custom"
            }
        }
        return "\(minutes) Minutes"
    }
    
    static func preset(for minutes: Int) -> TimerPreset {
        TimerPreset(rawValue: minutes) ?? .custom
    }
}
