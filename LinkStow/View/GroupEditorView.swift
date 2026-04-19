import SwiftUI
import SwiftData
import UIKit


// MARK: - DEMO GROUP CONSTANTS - 
let DEMO_GROUP_CORNER_RADIUS: CGFloat = DEVICE_CORNER_RADIUS
let DEMO_GROUP_HEIGHT: CGFloat = DEMO_GROUP_CORNER_RADIUS*2
let DEMO_GROUP_PADDING: CGFloat = 16

let DEMO_ICON_MAX_HEIGHT: CGFloat = DEMO_GROUP_HEIGHT - DEMO_GROUP_PADDING*2
let DEMO_ICON_MAX_WIDTH: CGFloat = DEMO_ICON_MAX_HEIGHT 
let DEMO_GROUP_SPACING: CGFloat = DEMO_GROUP_PADDING 
let DEMO_GROUP_FONT_SIZE: CGFloat = 30

// MARK: - ICON OPTION CONSTANTS -
let ICON_OPTION_SIZE: CGFloat = 40
let ICON_OPTION_SELECTED_SIZE: CGFloat = 52
let ICON_OPTION_SELECTED_STROKE_WIDTH: CGFloat = 3

// MARK: - GROUP EDITOR VIEW -
struct GroupEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GroupModel.name) private var groupsList: [GroupModel]
    
    var mainController: MainController
    var editGroup: GroupModel
    var isNew: Bool = true

    // Form state
    @State private var groupName: String  = ""
    @State private var selectedIcon: String  = "link"
    @State private var selectedEmoji: String  = "🔗"
    @State private var selectedSymbolType: SymbolType  = .icon
    @State private var selectedColor: Color = .blue
    @State private var imgSelectionIndex: Int = 0
    @State private var showDeleteConfirmation: Bool = false


    // Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PADDING) {
                    demoCard
                    colorGrid
                    symbolSelector
                    Spacer(minLength: PADDING)
                }
                .padding(PADDING)
            }
            .scrollIndicators(.hidden)
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle(isNew ? "New Group" : "Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {   
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                if !isNew {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", systemImage: "trash") {
                            showDeleteConfirmation = true
                        }
                        .tint(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        if !isNew {
                            mainController.updateGroup(
                                groupModel: editGroup,
                                name: groupName,
                                icon: selectedIcon,
                                emoji: selectedEmoji,
                                color: selectedColor,
                                type: selectedSymbolType
                            )
                        } else {
                            mainController.addGroup(
                                groupModel: editGroup,
                                name: groupName,
                                icon: selectedIcon,
                                emoji: selectedEmoji,
                                color: selectedColor,
                                type: selectedSymbolType,
                            )
                        }
                        dismiss()
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                groupName = editGroup.name
                selectedIcon = editGroup.symbol.icon
                selectedEmoji = editGroup.symbol.emoji
                selectedSymbolType = editGroup.symbol.getSymbolType()
                selectedColor = editGroup.getSymbolColor()
                imgSelectionIndex = editGroup.symbol.getSymbolType() == .icon ? 0 : 1
            }
            .alert("Delete Group", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    showDeleteConfirmation = false
                }
                Button("Delete", role: .destructive) {
                    handleDeleteConfirmation(confirmed: true)
                }
            } message: {
                Text("Are you sure you want to delete \"\(editGroup.name)\"? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - DELETE CONFIRMATION -
    private func handleDeleteConfirmation(confirmed: Bool) {
        if confirmed {
            mainController.deleteGroup(group: editGroup)
            dismiss()
        }
    }

    // MARK: - Demo Card

    // Demo Card
    private var demoCard: some View {
        HStack(spacing: DEMO_GROUP_SPACING) {
            demoSymbolView
            TextField("Group Name", text: $groupName)
                .font(.system(size: DEMO_GROUP_FONT_SIZE)).bold()
                .foregroundStyle(Color.white)
        }
        .padding(DEMO_GROUP_PADDING)
        .frame(maxWidth: .infinity)
        .frame(height: DEMO_GROUP_HEIGHT)
        .background(
            RoundedRectangle(cornerRadius: DEMO_GROUP_CORNER_RADIUS)
                .fill(selectedColor.gradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: DEMO_GROUP_CORNER_RADIUS))
    }

    // Demo Symbol View
    private var demoSymbolView: some View {
        ZStack {
            if selectedSymbolType == .icon {
                Image(systemName: selectedIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: DEMO_ICON_MAX_WIDTH, maxHeight: DEMO_ICON_MAX_HEIGHT)
            } else if selectedSymbolType == .emoji {
                Text(selectedEmoji)
                    .font(.system(size: DEMO_GROUP_FONT_SIZE)).bold()
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: DEMO_ICON_MAX_WIDTH, maxHeight: DEMO_ICON_MAX_HEIGHT)
            } else {
                // Fallback (shouldn't happen for groups)
                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: DEMO_ICON_MAX_WIDTH, maxHeight: DEMO_ICON_MAX_HEIGHT)
            }
        }
    }

    // MARK: - Color Grid

    // Color Grid
    private var colorGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                // Default color choices
                ForEach(Array(colorChoices.enumerated()), id: \.offset) { _, color in
                    Button(action: { 
                        selectedColor = color
                    }) {
                        ZStack {
                            Circle().fill(color)
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Circle()
                                .strokeBorder(Color.gray.opacity(color == selectedColor ? 0.5 : 0), lineWidth:ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
                // Color picker
                ZStack {
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(1.5) // visually enlarge the well
                        .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                    Circle()
                        .strokeBorder(Color.gray.opacity(((selectedColor == selectedColor) && !(colorChoices.contains(selectedColor))) ? 0.5 : 0), lineWidth:ICON_OPTION_SELECTED_STROKE_WIDTH)
                        .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS).fill(Color(UIColor.systemBackground)))
    }

    // Symbol Selector
    private var symbolSelector: some View {
        VStack(alignment: .leading, spacing: PADDING) {
            Picker("", selection: $imgSelectionIndex) {
                Text("Icons").tag(0)
                Text("Emoji").tag(1)
            }
            .pickerStyle(.segmented)
            .onChange(of: imgSelectionIndex) { _, newValue in
                // Update symbol type when picker changes
                if newValue == 0 {
                    // Switch to icon - if current symbol is emoji, set to first icon
                    if selectedSymbolType == .emoji {
                        selectedIcon = iconChoices.first ?? "list.bullet"
                        selectedSymbolType = .icon
                    }
                } else {
                    // Switch to emoji - if current symbol is icon, set to first emoji
                    if selectedSymbolType == .icon {
                        selectedEmoji = emojiChoices.first ?? "😀"
                        selectedSymbolType = .emoji
                    }
                }
            }

            if imgSelectionIndex == 0 {
                iconGrid
            } else {
                emojiGrid
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS).fill(Color(UIColor.systemBackground)))
    }

    // Icon Grid
    private var iconGrid: some View {
        VStack(alignment: .leading, spacing: PADDING) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                ForEach(iconChoices, id: \.self) { symbolOption in
                    Button(action: { setSymbol(symbol: symbolOption) }) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Image(systemName: symbolOption)
                                .symbolVariant(.fill)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.gray)
                            Circle()
                                .strokeBorder(Color.gray.opacity(symbolOption == selectedIcon ? 0.5 : 0), lineWidth:ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // Emoji Grid
    private var emojiGrid: some View {
        VStack(alignment: .leading, spacing: PADDING) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                ForEach(emojiChoices, id: \.self) { emoji in
                    Button(action: { setSymbol(symbol: emoji) }) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Text(emoji)
                                .font(.system(size: 20, weight: .semibold))
                            Circle()
                                .strokeBorder(Color.gray.opacity(emoji == selectedEmoji ? 0.5 : 0), lineWidth:ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - HELPER FUNCTIONS -
    // Set Symbol
    private func setSymbol(symbol: String) {
        if iconChoices.contains(symbol) {
            selectedSymbolType = .icon
            selectedIcon = symbol
        } else if emojiChoices.contains(symbol) {
            selectedSymbolType = .emoji
            selectedEmoji = symbol
        } else {
            fatalError("Symbol is not an icon or emoji")
        }
    }
}


