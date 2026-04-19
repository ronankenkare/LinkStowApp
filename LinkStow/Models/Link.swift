import SwiftUI
import Foundation
import SwiftData


let SMALL_SYMBOL: CGFloat = GROUP_HEIGHT
let LARGE_SYMBOL: CGFloat = DEVICE_CORNER_RADIUS * 2



// Link
@Model
class LinkModel {

    // Connect to LinkMetadataService
    @Transient var linkService: LinkMetadataService = LinkMetadataService()

    // MARK: - Attributes -
    
    var url: String
    var title: String = ""
    var caption: String = ""

    var symbol: SymbolModel = SymbolModel(
        faviconData: nil, 
        icon: "link", 
        emoji: "🔗", 
        color: Color.blue,
        type: SymbolType.icon
    )

    var reminderEnabled: Bool = false
    var reminderDate: Date? = nil
    var reminderAllDay: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \GroupModel.links)
    var groups: [GroupModel] = []
    var isHidden: Bool = false


    // MARK: - INITIALIZATION -
    init(
        url: String,
        title: String,
        caption: String,
        faviconImage: Data?
    ) {
        self.url = url
        self.title = title
        self.caption = caption
        self.symbol = SymbolModel(
            faviconData: faviconImage,
            icon: "link",
            emoji: "🔗",
            color: Color.blue,
            type: faviconImage != nil ? SymbolType.favicon : SymbolType.icon
        )
    }

    // MARK: - UPDATE LINK - 
    func updateLink(
        title: String,
        caption: String,
        
        symbolType: SymbolType,
        symbolIcon: String,
        symbolEmoji: String,
        symbolColor: Color,

        reminderEnabled: Bool,
        reminderDate: Date,
        reminderAllDay: Bool,

        groups: [GroupModel],
        isHidden: Bool
    ) {
        // Update link 
        self.title = title
        self.caption = caption

        // Update symbol
        self.symbol.updateSymbol(
            icon: symbolIcon, 
            emoji: symbolEmoji, 
            color: symbolColor, 
            type: symbolType
        )

        // Update reminder
        if reminderEnabled {
            self.reminderEnabled = true
            self.reminderDate = reminderDate
            self.reminderAllDay = reminderAllDay
        } else {
            self.reminderEnabled = false
            self.reminderDate = nil
            self.reminderAllDay = false
        }

        // SwiftData automatically maintains the inverse relationship (GroupModel.links)
        // via the @Relationship(deleteRule: .nullify, inverse: \GroupModel.links) declaration
        if isHidden {
            self.isHidden = true
            self.groups = []
        } else {
            self.isHidden = false
            self.groups = groups
        }
    }

    // MARK: - FAVICON FUNCTIONS -

    // Get the favicon of the link
    func getFavicon() -> Data? {
        return symbol.faviconData
    }

    // MARK: - GROUP FUNCTIONS -

    func checkLinkInGroup(group: GroupModel) -> Bool {
        return groups.contains { $0 === group }
    }

    // MARK: - HIDDEN FUNCTIONS -

    // Check if the link is hidden
    func isLinkHidden() -> Bool {
        return isHidden
    }

    // Hide the link
    func toggleHideLink() {
        self.isHidden = !isHidden
    }

    // MARK: - View Symbol - 
    func viewSymbol(small: Bool) -> some View {
        ZStack {
            switch symbol.getSymbolType() {
            case .favicon:
                faviconView(small: small)
            case .icon:
                iconView(small: small)
            case .emoji:
                emojiView(small: small)
            }
        }
    }
    
    private func symbolHeight(small: Bool) -> CGFloat {
        if small {
            return SMALL_SYMBOL
        } else {
            return LARGE_SYMBOL
        }
    }

    private func faviconView(small: Bool) -> some View {
        ZStack {
            if let faviconData = symbol.faviconData,
                let uiImage = UIImage(data: faviconData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(symbolHeight(small: small)/4)
                    .frame(width: symbolHeight(small: small), height: symbolHeight(small: small))
                    .glassEffect(.regular.tint(Color.blue.opacity(0.8)).interactive())
                    .contentShape(Circle())
            } else {
                Image(systemName: "link")
                    .padding(symbolHeight(small: small)/4)
                    .frame(width: symbolHeight(small: small), height: symbolHeight(small: small))
                    .foregroundColor(Color.white)
                    .glassEffect(.regular.tint(Color.blue.opacity(0.8)).interactive())
                    .contentShape(Circle())
            }
        }
    }

    private func iconView(small: Bool) -> some View {
        Image(systemName: symbol.icon)
            .padding(symbolHeight(small: small)/4)
            .frame(width: symbolHeight(small: small), height: symbolHeight(small: small))
            .foregroundColor(Color.white)
            .glassEffect(.regular.tint(Color(symbol.getColor()).opacity(0.8)).interactive())
            .contentShape(Circle())
    }

    private func emojiView(small: Bool) -> some View {
        Text(symbol.emoji)
            .padding(symbolHeight(small: small)/4)
            .frame(width: symbolHeight(small: small), height: symbolHeight(small: small))
            .foregroundColor(Color.white)
            .glassEffect(.regular.tint(Color(symbol.getColor()).opacity(0.8)).interactive())
            .contentShape(Circle())
    }


}
