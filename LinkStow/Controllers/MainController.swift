import SwiftUI
import SwiftData
import Foundation
import UIKit

@Observable
final class MainController {
    let linkService: LinkMetadataService = LinkMetadataService()
    
    var modelContext: ModelContext

    // MARK: - INITIALIZER -
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }


    // MARK: - LINK FUNCTIONS -

    // Create Link without inserting to ModelContext
    func createLink(
        url: String,
        title: String,
        caption: String,
        faviconImage: Data?
    ) -> LinkModel {
        let linkModel = LinkModel(
            url: url,
            title: title,
            caption: caption,
            faviconImage: faviconImage
        )
        return linkModel
    }
    

    // Add Link to ModelContext
    func addLink(
        linkModel: LinkModel,

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
        linkModel.updateLink(
            title: title,
            caption: caption,

            symbolType: symbolType,
            symbolIcon: symbolIcon,
            symbolEmoji: symbolEmoji,
            symbolColor: symbolColor,

            reminderEnabled: reminderEnabled,
            reminderDate: reminderDate,
            reminderAllDay: reminderAllDay,

            groups: groups,
            isHidden: isHidden
        )
        modelContext.insert(linkModel)
    }

    // Update Link in ModelContext
    func updateLink(
        linkModel: LinkModel,

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
        linkModel.updateLink(
            title: title,
            caption: caption,

            symbolType: symbolType,
            symbolIcon: symbolIcon,
            symbolEmoji: symbolEmoji,
            symbolColor: symbolColor,

            reminderEnabled: reminderEnabled,
            reminderDate: reminderDate,
            reminderAllDay: reminderAllDay,

            groups: groups,
            isHidden: isHidden
        )
        try? modelContext.save()
    }

    // Delete Link from ModelContext
    func deleteLink(link: LinkModel) {
        modelContext.delete(link)
        try? modelContext.save()
    }

    // Verify Link
    func verifyLink(from urlString: String) async throws -> String? {
        return try await linkService.verifyLink(from: urlString)
    }

    // Fetch Website Title
    func fetchWebsiteTitle(from urlString: String) async throws -> String? {
        return try await linkService.fetchWebsiteTitle(from: urlString)
    }

    // Fetch Website Description
    func fetchWebsiteDescription(from urlString: String) async throws -> String? {
        return try await linkService.fetchWebsiteDescription(from: urlString)
    }
    
    // Fetch Website Icon
    func fetchWebsiteIcon(from urlString: String) async throws -> Data? {
        return try await linkService.fetchWebsiteIcon(from: urlString)
    }

    // Open URL in user's browser
    func openLink(urlString: String) {
        guard let url = URL(string: urlString), isValidURLScheme(url) else { return }
        UIApplication.shared.open(url)
    }

    func isValidURLScheme(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return ["http", "https"].contains(scheme)
    }

    // MARK: - GROUP FUNCTIONS -

    // Create New Group
    func createNewGroup() -> GroupModel {
        let groupModel = GroupModel(
            name: "",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .icon,
        )
        return groupModel
    }
    
    // Add Group to ModelContext
    func addGroup(
        groupModel: GroupModel,
        name: String,
        icon: String,
        emoji: String,
        color: Color,
        type: SymbolType,
    ) {
        groupModel.updateGroup(name: name, icon: icon, emoji: emoji, color: color, type: type)
        modelContext.insert(groupModel)
    }

    // Update Group in ModelContext
    func updateGroup(
        groupModel: GroupModel,
        name: String,
        icon: String,
        emoji: String,
        color: Color,
        type: SymbolType,
    ) {
        groupModel.updateGroup(
            name: name,
            icon: icon,
            emoji: emoji,
            color: color,
            type: type,
        )
        try? modelContext.save()
    }
    
    // Delete Group from ModelContext — SwiftData's .nullify delete rule removes the group from all link arrays
    func deleteGroup(group: GroupModel) {
        modelContext.delete(group)
        try? modelContext.save()
    }

}
