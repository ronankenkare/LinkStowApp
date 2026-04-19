import SwiftUI
import SwiftData

@Observable
final class LinkEditorViewModel {

    // MARK: - Symbol State
    var symbolSelection: SymbolType = .icon
    var showSymbolCustomization: Bool = false
    var showIconEmojiPicker: Bool = false
    var showColorPicker: Bool = false
    var linkFavicon: Data? = nil
    var selectedIcon: String = "link"
    var selectedEmoji: String = "🔗"
    var selectedColor: Color = colorChoices[5]

    // MARK: - Link Fields
    var linkTitle: String = ""
    var linkCaption: String = ""
    var linkUrl: String = ""

    var showLinkTitleClearButton: Bool {
        !linkTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Reminder Fields
    var reminderDateToggleOn: Bool = false
    var reminderTimeToggleOn: Bool = false
    var showDatePicker: Bool = false
    var showTimePicker: Bool = false
    var reminderDate: Date = Date()

    // MARK: - Groups / Visibility
    var selectedGroups: [GroupModel] = []
    var isHidden: Bool = false
    var isAuthenticating: Bool = false

    // MARK: - Layout
    var notesEditorHeight: CGFloat = 0

    // MARK: - Initialize

    func initialize(from link: LinkModel, isNew: Bool) {
        reset()
        linkUrl = link.url
        linkTitle = link.title
        linkCaption = link.caption

        if isNew {
            linkFavicon = link.getFavicon()
            symbolSelection = linkFavicon != nil ? .favicon : .icon
            showSymbolCustomization = symbolSelection == .icon || symbolSelection == .emoji
            isHidden = false
            selectedGroups = []
        } else {
            symbolSelection = link.symbol.getSymbolType()
            selectedIcon = link.symbol.icon
            selectedEmoji = link.symbol.emoji
            selectedColor = link.symbol.getColor()
            showSymbolCustomization = symbolSelection == .icon || symbolSelection == .emoji

            if link.reminderEnabled {
                reminderDateToggleOn = true
                reminderDate = link.reminderDate ?? Date()
                reminderTimeToggleOn = !link.reminderAllDay
            }

            isHidden = link.isHidden
            selectedGroups = link.isHidden ? [] : link.groups
        }

        updateNotesEditorHeight()
    }

    // MARK: - Save

    func save(link: LinkModel, isNew: Bool, mainController: MainController) {
        if isNew {
            mainController.addLink(
                linkModel: link,
                title: linkTitle,
                caption: linkCaption,
                symbolType: symbolSelection,
                symbolIcon: selectedIcon,
                symbolEmoji: selectedEmoji,
                symbolColor: selectedColor,
                reminderEnabled: reminderDateToggleOn,
                reminderDate: reminderDate,
                reminderAllDay: reminderTimeToggleOn,
                groups: selectedGroups,
                isHidden: isHidden
            )
        } else {
            mainController.updateLink(
                linkModel: link,
                title: linkTitle,
                caption: linkCaption,
                symbolType: symbolSelection,
                symbolIcon: selectedIcon,
                symbolEmoji: selectedEmoji,
                symbolColor: selectedColor,
                reminderEnabled: reminderDateToggleOn,
                reminderDate: reminderDate,
                reminderAllDay: reminderTimeToggleOn,
                groups: selectedGroups,
                isHidden: isHidden
            )
        }
        reset()
    }

    // MARK: - Reset

    func reset() {
        linkUrl = ""
        linkTitle = ""
        linkCaption = ""

        symbolSelection = .icon
        linkFavicon = nil
        selectedIcon = "link"
        selectedEmoji = "🔗"
        selectedColor = .blue

        showSymbolCustomization = false
        showIconEmojiPicker = false
        showColorPicker = false

        reminderDateToggleOn = false
        reminderDate = Date()
        reminderTimeToggleOn = false
        showDatePicker = false
        showTimePicker = false

        selectedGroups = []
        isHidden = false
        isAuthenticating = false

        notesEditorHeight = 0
    }

    // MARK: - Toggle Hidden (with auth guard)

    func toggleHidden() async {
        if isHidden {
            await MainActor.run { isHidden = false }
        } else if !isAuthenticating {
            await MainActor.run { isAuthenticating = true }
            do {
                let result = try await authenticateUser(activation: false)
                await MainActor.run {
                    isAuthenticating = false
                    if result { isHidden = true }
                }
            } catch {
                await MainActor.run { isAuthenticating = false }
            }
        }
    }

    // MARK: - Notes Height

    func updateNotesEditorHeight() {
        let lineCount = calculateLineCount(from: linkCaption)
        notesEditorHeight = CGFloat(min(lineCount, NOTES_EDITOR_MAX_LINES)) * NOTES_EDITOR_SINGLE_LINE_HEIGHT
    }

    private func calculateLineCount(from text: String, charactersPerLine: Int = 50) -> Int {
        if text.isEmpty { return 1 }
        let lineSegments = text.components(separatedBy: .newlines)
        var total = 0
        for segment in lineSegments {
            total += max(1, Int(ceil(Double(segment.count) / Double(charactersPerLine))))
        }
        return max(1, total)
    }
}
