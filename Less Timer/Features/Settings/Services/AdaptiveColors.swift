import SwiftUI

extension Color {
    static var adaptivePrimaryFont: Color {
        #if os(watchOS)
        return Color("watchPrimaryFont")
        #else
        return Color("primaryFont")
        #endif
    }
    
    static var adaptiveSecondaryFont: Color {
        #if os(watchOS)
        return Color("watchSecondaryFont")
        #else
        return Color("secondaryFont")
        #endif
    }
    
    static var adaptiveBackground: Color {
        #if os(watchOS)
        return Color("watchBackground")
        #else
        return Color("background")
        #endif
    }
    
    static var adaptiveAccent: Color {
        #if os(watchOS)
        return Color("watchAccent")
        #else
        return Color("accent")
        #endif
    }
}
