import SwiftUI
import SwiftData

// MARK: - Group Model
@Model
final class GroupModel {
    var name: String = ""
    var symbol: SymbolModel = SymbolModel(
        faviconData: nil,
        icon: "link",
        emoji: "🔗", 
        color: Color.blue,
        type: SymbolType.icon
    )
    
    // Inverse relationship - SwiftData automatically maintains this based on the @Relationship in LinkModel
    var links: [LinkModel] = []

    init(
        name: String = "",
        icon: String = "link",
        emoji: String = "🔗",
        color: Color = Color.blue,
        type: SymbolType = .icon
    ) {
        self.name = name
        self.symbol = SymbolModel(
            faviconData: nil,
            icon: icon,
            emoji: emoji,
            color: color,
            type: type,
        )
    }

    // MARK: - UPDATE GROUP -
    func updateGroup(
        name: String,
        icon: String,
        emoji: String,
        color: Color,
        type: SymbolType,
    ) {
        self.name = name
        self.symbol = SymbolModel(
            faviconData: nil,
            icon: icon,
            emoji: emoji,
            color: color,
            type: type,
        )
    }

    func getSymbolColor() -> Color {
        return symbol.getColor()
    }
}


// MARK: - Group View
func groupBubble(group: GroupModel, selected: Bool) -> some View {
    HStack(spacing: GROUP_BUBBLE_SPACING) {
        ZStack {
            if group.symbol.getSymbolType() == .icon {
                Image(systemName: group.symbol.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            } else if group.symbol.getSymbolType() == .emoji {
                Text(group.symbol.emoji)
                    .font(.system(size: 16)).bold()
            } else {
                // Fallback for favicon (shouldn't happen for groups, but handle gracefully)
                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        Text(group.name)
            .font(.subheadline).bold()
    }
    .padding(GROUP_PADDING)
    .frame(height: GROUP_HEIGHT)
    .foregroundColor(selected ? Color.white : Color("GroupForeground"))
    .glassEffect(.regular.tint(selected ? group.getSymbolColor().opacity(0.8) : Color("GroupBackground").opacity(0.8)).interactive())
    .contentShape(Capsule())
}
