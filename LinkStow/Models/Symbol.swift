import SwiftUI
import Foundation
import UIKit
import SwiftData


let iconChoices: [String] = [
    "face.smiling.fill",    "list.bullet",          "bookmark.fill",    "key.fill",             "gift.fill",                    "birthday.cake.fill",
    "graduationcap.fill",   "backpack.fill",        "ruler.fill",       "doc.richtext.fill",    "book.fill",                    "creditcard.fill",
    "banknote.fill",        "dumbbell.fill",        "figure.run",       "fork.knife",           "wineglass.fill",               "pills.fill",
    "stethoscope",          "chair.lounge.fill",    "house.fill",       "building.2.fill",      "building.columns.fill",        "tent.fill",
    "display",              "tv",                   "music.note",       "desktopcomputer",      "gamecontroller",               "headphones",
    "leaf.fill",            "carrot",               "person",           "person.2",             "person.3",                     "pawprint.fill",
    "teddybear.fill",       "fish",                 "basket",           "cart",                 "bag",                          "shippingbox.fill",
    "soccerball",           "baseball",             "basketball",       "football",             "tennis.racket",                "tram.fill",
    "airplane",             "sailboat",             "car",              "beach.umbrella.fill",  "sun.max",                      "moon",
    "drop",                 "snowflake",            "flame",            "briefcase.fill",       "wrench.and.screwdriver.fill",  "scissors",
    "pencil.and.ruler",     "curlybraces",          "lightbulb",        "bubble.left.fill",     "link",                         "asterisk",
    "square.fill",          "circle.fill",          "triangle.fill",    "diamond.fill",         "heart.fill",                   "star.fill"
]

let emojiChoices: [String] = [
    "😀", "😁", "😂", "🥰", "😍", "🤩",
    "🎯", "🏃", "🏋️", "🎁", "🎉", "📚",
    "📝", "🏫", "💼", "💳", "💡", "📈",
    "🍎", "🍔", "🍷", "☕️", "🏠", "🏢", 
    "💬", "🗂️", "💻", "💯", "🧠", "🤝", 
    "📅", "🧑‍💻", "🎨", "⚙️", "💾", "🤖", 
    "🌍", "🎮", "🎵", "☕", "❤️", "🫶", 
    "🌈", "🪙", "⭐", "🔒", "📦", "🧩", 
    "🧭", "✨", "🔗", "🏆", "🪄", "🪩", 
    "📁", "🧮", "🧪", "🧬", "🧑‍🏫", "📸", 
    "🎬", "🎧", "🧰", "🛰️", "📡", "🔋", 
    "🧱", "🧑‍🚀", "🌄", "🏝️", "🏔️", "🎭", 
]

let colorChoices: [Color] = [
    .red, .orange, .yellow, .green, .blue.opacity(0.7), .blue,
    .purple, Color(red: 0.70, green: 0.55, blue: 0.37), .gray, Color(red: 0.87, green: 0.75, blue: 0.72),
    .pink
]

// Symbol Type Enum
enum SymbolType: String, Codable, CaseIterable, Identifiable {
    case favicon
    case icon
    case emoji
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .favicon: return "Favicon"
        case .icon: return "Icon"
        case .emoji: return "Emoji"
        }
    }
}

// Symbol
@Model
class SymbolModel {
    var faviconData: Data? = nil
    var icon: String = "link"
    var emoji: String = "🔗"
    var symbolTypeRaw: String = SymbolType.icon.rawValue
    var colorR: Double = 0
    var colorG: Double = 0
    var colorB: Double = 0
    var alpha: Double = 0
    

    init(
        faviconData: Data? = nil,
        icon: String,
        emoji: String,
        color: Color,
        type: SymbolType
    ) {
        self.faviconData = faviconData
        self.icon = icon
        self.emoji = emoji
        setColor(color: color)
        setSymbolType(type: type)
    }



    func updateSymbol(
        icon: String,
        emoji: String,
        color: Color,
        type: SymbolType
    ) {
        self.icon = icon
        self.emoji = emoji
        setColor(color: color)
        setSymbolType(type: type)
    }


    // MARK: - COLOR FUNCTIONS -
    
    // Set the color of the symbol
    private func setColor(color: Color) {
        let components = colorComponents(color: color)
        if let components = components {
            self.colorR = components.red
            self.colorG = components.green
            self.colorB = components.blue
            self.alpha = components.alpha
        }
    }

    // Get the color of the symbol
    func getColor() -> Color {
        return Color(red: self.colorR, green: self.colorG, blue: self.colorB, opacity: self.alpha)
    }


    // MARK: - SYMBOL TYPE FUNCTIONS -
    
    // Set the symbol type
    private func setSymbolType(type: SymbolType) {
        self.symbolTypeRaw = type.rawValue
    }

    // Get the symbol type
    func getSymbolType() -> SymbolType {
        return SymbolType(rawValue: symbolTypeRaw) ?? .icon
    }



    // MARK: - HELPER FUNCTIONS -

    // Convert a Color to its RGB components
    private func colorComponents(color: Color) -> (red: Double, green: Double, blue: Double, alpha: Double)? {    
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (Double(red), Double(green), Double(blue), Double(alpha))
        } else {
            return nil
        }
    }
}
