import SwiftUI
import SwiftData
import UIKit



let NOTES_EDITOR_MAX_LINES: Int = 7
let NOTES_EDITOR_SINGLE_LINE_HEIGHT: CGFloat = 28

struct LinkEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GroupModel.name) private var groupsList: [GroupModel]
    @AppStorage("hiddenGroupActive") private var hiddenGroupActive: Bool = false

    // MARK: - VIEW INPUTS -
    var mainController: MainController
    var link: LinkModel
    var isNew: Bool = false

    // MARK: - VIEW MODEL -
    @State private var viewModel = LinkEditorViewModel()

    // MARK: - PRESENTATION STATE (view-only) -
    @State private var editingGroups: Bool = false
    @State private var groupEditorItem: GroupEditorItem? = nil

    struct GroupEditorItem: Identifiable {
        let id = UUID()
        let group: GroupModel
        let isNew: Bool
    }


    // MARK: - BODY -
    var body: some View {
        NavigationStack {
            Form {
                if !editingGroups {
                    symbolSection
                    linkNameSection
                    // reminderSection
                }
                groupsSection
            }
            .navigationTitle(isNew ? "New Link" : "Edit Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // MARK: Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        viewModel.reset()
                        dismiss()
                    }
                }

                // MARK: Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        viewModel.save(link: link, isNew: isNew, mainController: mainController)
                        dismiss()
                    }
                    .disabled(viewModel.linkTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                viewModel.initialize(from: link, isNew: isNew)
            }
            .task {
                viewModel.updateNotesEditorHeight()
            }
            .sheet(item: $groupEditorItem) { item in
                GroupEditorView(mainController: mainController, editGroup: item.group, isNew: item.isNew)
            }
        }
    }
}



// MARK: - SYMBOL SECTION
private extension LinkEditorView {

    // MARK: Symbol Section
    private var symbolSection: some View {
        Section {
            VStack(spacing: PADDING) {
                previewSymbolView
                symbolPicker
            }
            .listRowSeparator(.hidden)
            if viewModel.showSymbolCustomization {
                colorDropdown
                if viewModel.showColorPicker {
                    colorGrid
                }
                iconEmojiDropdown
                if viewModel.showIconEmojiPicker && viewModel.symbolSelection == .icon {
                    iconGrid
                } else if viewModel.showIconEmojiPicker && viewModel.symbolSelection == .emoji {
                    emojiGrid
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showSymbolCustomization)
    }

    // MARK: Preview Symbol View
    private var previewSymbolView: some View {
        ZStack {
            switch viewModel.symbolSelection {
            case .favicon:
                faviconPreviewView
            case .icon:
                iconPreviewView
            case .emoji:
                emojiPreviewView
            }
        }
        .animation(.easeInOut, value: viewModel.symbolSelection)
        .animation(.easeInOut, value: viewModel.selectedIcon)
        .animation(.easeInOut, value: viewModel.selectedEmoji)
        .animation(.easeInOut, value: viewModel.selectedColor)
    }

    // MARK: Favicon Preview View
    private var faviconPreviewView: some View {
        ZStack {
            if let faviconData = link.symbol.faviconData,
                let uiImage = UIImage(data: faviconData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(LARGE_SYMBOL/4)
                    .frame(width: LARGE_SYMBOL, height: LARGE_SYMBOL)
                    .glassEffect(.regular.tint(Color.clear.opacity(0.8)).interactive())
                    .contentShape(Circle())
            } else {
                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
                    .padding(LARGE_SYMBOL/4)
                    .frame(width: LARGE_SYMBOL, height: LARGE_SYMBOL)
                    .foregroundColor(Color.white)
                    .glassEffect(.regular.tint(Color.blue.opacity(0.8)).interactive())
                    .contentShape(Circle())
            }
        }
    }

    // MARK: Icon Preview View
    private var iconPreviewView: some View {
        Image(systemName: viewModel.selectedIcon)
            .resizable()
            .scaledToFit()
            .padding(LARGE_SYMBOL/4)
            .frame(width: LARGE_SYMBOL, height: LARGE_SYMBOL)
            .foregroundColor(Color.white)
            .glassEffect(.regular.tint(viewModel.selectedColor.opacity(0.8)).interactive())
            .contentShape(Circle())
    }

    // MARK: Emoji Preview View
    private var emojiPreviewView: some View {
        Text(viewModel.selectedEmoji)
            .font(.system(size: 36))
            .scaledToFit()
            .padding(LARGE_SYMBOL/8)
            .frame(width: LARGE_SYMBOL, height: LARGE_SYMBOL)
            .foregroundColor(Color.white)
            .glassEffect(.regular.tint(viewModel.selectedColor.opacity(0.8)).interactive())
            .contentShape(Circle())
    }

    // MARK: Symbol Picker
    private var symbolPicker: some View {
        @Bindable var vm = viewModel
        return Picker("", selection: $vm.symbolSelection) {
            ForEach(SymbolType.allCases) { selection in
                Text(selection.label).tag(selection)
            }
        }
        .animation(.easeInOut, value: viewModel.symbolSelection)
        .pickerStyle(.segmented)
        .onChange(of: viewModel.symbolSelection) { _, _ in
            withAnimation(.easeInOut) {
                viewModel.showSymbolCustomization = viewModel.symbolSelection == .icon || viewModel.symbolSelection == .emoji
                viewModel.showIconEmojiPicker = false
                viewModel.showColorPicker = false
            }
        }
    }

    // MARK: Color Dropdown
    private var colorDropdown: some View {
        HStack {
            Text("Color")
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(viewModel.showColorPicker ? 90 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                viewModel.showColorPicker.toggle()
                viewModel.showIconEmojiPicker = false
            }
        }
    }

    // MARK: Color Grid
    private var colorGrid: some View {
        @Bindable var vm = viewModel
        return VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                ForEach(colorChoices, id: \.self) { color in
                    Button(action: { vm.selectedColor = color }) {
                        ZStack {
                            Circle().fill(color)
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Circle()
                                .strokeBorder(Color.gray.opacity(color == vm.selectedColor ? 0.5 : 0), lineWidth: ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
                colorPickerControl
            }
        }
        .animation(.easeInOut, value: viewModel.showColorPicker)
    }

    // MARK: Color Picker
    private var colorPickerControl: some View {
        @Bindable var vm = viewModel
        return ZStack {
            ColorPicker("", selection: $vm.selectedColor, supportsOpacity: false)
                .labelsHidden()
                .scaleEffect(1.5)
                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
            Circle()
                .strokeBorder(Color.gray.opacity(!colorChoices.contains(vm.selectedColor) ? 0.5 : 0), lineWidth: ICON_OPTION_SELECTED_STROKE_WIDTH)
                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
        }
    }

    // MARK: Icon/Emoji Dropdown
    private var iconEmojiDropdown: some View {
        HStack {
            Text(viewModel.symbolSelection == .icon ? "Icon" : "Emoji")
                .animation(nil, value: viewModel.symbolSelection)
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(viewModel.showIconEmojiPicker ? 90 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                viewModel.showIconEmojiPicker.toggle()
                viewModel.showColorPicker = false
            }
        }
    }

    // MARK: Icon Grid
    private var iconGrid: some View {
        VStack(alignment: .leading, spacing: PADDING) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                ForEach(iconChoices, id: \.self) { symbolOption in
                    Button(action: { viewModel.selectedIcon = symbolOption }) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Image(systemName: symbolOption)
                                .symbolVariant(.fill)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.gray)
                            Circle()
                                .strokeBorder(Color.gray.opacity(symbolOption == viewModel.selectedIcon ? 0.5 : 0), lineWidth: ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showIconEmojiPicker)
    }

    // MARK: Emoji Grid
    private var emojiGrid: some View {
        VStack(alignment: .leading, spacing: PADDING) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PADDING), count: 6), spacing: PADDING) {
                ForEach(emojiChoices, id: \.self) { emoji in
                    Button(action: { viewModel.selectedEmoji = emoji }) {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: ICON_OPTION_SIZE, height: ICON_OPTION_SIZE)
                            Text(emoji)
                                .font(.system(size: 20, weight: .semibold))
                            Circle()
                                .strokeBorder(Color.gray.opacity(emoji == viewModel.selectedEmoji ? 0.5 : 0), lineWidth: ICON_OPTION_SELECTED_STROKE_WIDTH)
                                .frame(width: ICON_OPTION_SELECTED_SIZE, height: ICON_OPTION_SELECTED_SIZE)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showIconEmojiPicker)
    }
}



private extension LinkEditorView {

    // MARK: Link Name Section
    private var linkNameSection: some View {
        Section {
            linkTitleField
            linkCaptionField
            linkUrlField
        }
    }

    // MARK: Link Title Field
    private var linkTitleField: some View {
        @Bindable var vm = viewModel
        return HStack(spacing: 8) {
            TextField("Title", text: $vm.linkTitle)
                .font(.title3).bold()
            if viewModel.showLinkTitleClearButton {
                Button(action: { viewModel.linkTitle = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }

    // MARK: Link Caption Field
    private var linkCaptionField: some View {
        @Bindable var vm = viewModel
        return ZStack(alignment: .topLeading) {
            if viewModel.linkCaption.isEmpty {
                Text("Notes")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            TextEditor(text: $vm.linkCaption)
                .frame(minHeight: viewModel.notesEditorHeight, maxHeight: CGFloat(NOTES_EDITOR_MAX_LINES) * NOTES_EDITOR_SINGLE_LINE_HEIGHT)
                .scrollContentBackground(.hidden)
                .task(id: viewModel.linkCaption) {
                    viewModel.updateNotesEditorHeight()
                }
        }
    }

    // MARK: Link URL Field
    private var linkUrlField: some View {
        Text(viewModel.linkUrl)
            .foregroundColor(.secondary)
            .font(.subheadline)
            .lineLimit(1)
    }

    // MARK: Reminder Section
    private var reminderSection: some View {
        @Bindable var vm = viewModel
        return Section(header: Text("Reminder")) {

            Toggle(isOn: $vm.reminderDateToggleOn) {
                Label {
                    ZStack(alignment: .leading) {
                        if viewModel.reminderDateToggleOn {
                            Text(viewModel.reminderDate.formatted(date: .long, time: .omitted))
                                .foregroundColor(.blue)
                        } else {
                            Text("Date")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .animation(nil, value: viewModel.reminderDateToggleOn)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.gray)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    if viewModel.reminderDateToggleOn { viewModel.showDatePicker.toggle() }
                }
            }
            .onChange(of: viewModel.reminderDateToggleOn) { _, newValue in
                withAnimation(.easeInOut) {
                    viewModel.showDatePicker = newValue
                    if !newValue {
                        viewModel.reminderTimeToggleOn = false
                        viewModel.showTimePicker = false
                    }
                }
            }

            if viewModel.showDatePicker {
                DatePicker("", selection: $vm.reminderDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            Toggle(isOn: $vm.reminderTimeToggleOn) {
                Label {
                    ZStack(alignment: .leading) {
                        if viewModel.reminderTimeToggleOn {
                            Text(viewModel.reminderDate.formatted(date: .omitted, time: .shortened))
                                .foregroundColor(.blue)
                        } else {
                            Text("Time")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .animation(nil, value: viewModel.reminderDateToggleOn)
                    .animation(nil, value: viewModel.reminderTimeToggleOn)
                } icon: {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color.gray)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    if viewModel.reminderTimeToggleOn { viewModel.showTimePicker.toggle() }
                }
            }
            .onChange(of: viewModel.reminderTimeToggleOn) { _, newValue in
                withAnimation(.easeInOut) {
                    if newValue { viewModel.reminderDateToggleOn = true }
                    viewModel.showTimePicker = newValue
                }
            }

            if viewModel.showTimePicker {
                DatePicker("", selection: $vm.reminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Groups Section
    private var groupsSection: some View {
        Section(header: groupsSectionHeader) {
            if groupsList.isEmpty && !hiddenGroupActive && !editingGroups {
                noGroupsView
            } else {
                FlowLayout(spacing: GROUP_PADDING) {
                    ForEach(groupsList, id: \.persistentModelID) { group in
                        groupBubbleView(group: group)
                    }
                    if hiddenGroupActive && !editingGroups {
                        hiddenGroupView()
                    }
                    addGroupButtonView
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: Group Bubble View
    private func groupBubbleView(group: GroupModel) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                if editingGroups {
                    groupEditorItem = GroupEditorItem(group: group, isNew: false)
                } else {
                    if viewModel.selectedGroups.contains(where: { $0 === group }) {
                        viewModel.selectedGroups.removeAll { $0 === group }
                    } else {
                        viewModel.selectedGroups.append(group)
                    }
                }
            }
        }) {
            groupBubble(group: group, selected: (!viewModel.isHidden && viewModel.selectedGroups.contains(where: { $0 === group })) || editingGroups)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isHidden && !editingGroups)
        .contentShape(Capsule())
    }

    // MARK: Hidden Group View
    private func hiddenGroupView() -> some View {
        Button(action: {
            Task { await viewModel.toggleHidden() }
        }) {
            filterHiddenBubble(filterHiddenSelected: viewModel.isHidden)
        }
        .buttonStyle(.plain)
    }

    // MARK: Filter Hidden Content View
    private func filterHiddenBubble(filterHiddenSelected: Bool) -> some View {
        ZStack {
            if filterHiddenSelected {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding(GROUP_PADDING)
        .frame(width: GROUP_HEIGHT, height: GROUP_HEIGHT)
        .foregroundColor(filterHiddenSelected ? Color.white : Color("GroupForeground"))
        .glassEffect(.regular.tint(filterHiddenSelected ? Color("GroupBackgroundSelected").opacity(0.8) : Color("GroupBackground").opacity(0.8)).interactive())
        .contentShape(Capsule())
    }

    // MARK: Add Group View
    private var addGroupButtonView: some View {
        Button(action: {
            groupEditorItem = GroupEditorItem(group: mainController.createNewGroup(), isNew: true)
        }) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .padding(GROUP_PADDING)
        .frame(width: GROUP_HEIGHT, height: GROUP_HEIGHT)
        .glassEffect(.regular.tint(Color("GroupBackgroundSelected").opacity(0.8)).interactive())
        .contentShape(Circle())
    }

    // MARK: No Groups View
    private var noGroupsView: some View {
        VStack(spacing: PADDING) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .frame(width: 100, height: 100)
                .glassEffect(.clear, in: .circle)
            Text("No groups yet")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            Text("Create your first group to organize your links")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: {
                groupEditorItem = GroupEditorItem(group: mainController.createNewGroup(), isNew: true)
            }) {
                Label("Add Group", systemImage: "plus.circle.fill")
                    .font(.headline).bold()
                    .padding(PADDING)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color("AddButton")
                            .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
                    )
                    .foregroundStyle(Color.white)
            }
        }
        .padding(PADDING)
    }

    // MARK: Groups Section Header
    private var groupsSectionHeader: some View {
        HStack {
            Text("Groups")
            Spacer()
            if !groupsList.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut) {
                        editingGroups.toggle()
                    }
                }) {
                    Text(editingGroups ? "Done" : "Edit")
                        .foregroundColor(.white)
                }
                .padding(GROUP_PADDING/2)
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(Color("GroupBackgroundSelected").opacity(0.8)).interactive())
                .contentShape(Capsule())
            }
        }
    }
}




// MARK: - FLOW LAYOUT -
private struct FlowLayout: Layout {
    var spacing: CGFloat = GROUP_PADDING
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        var totalWidth: CGFloat = 0, totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0, lineHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let sz = subview.sizeThatFits(.unspecified)
            if lineWidth + sz.width > maxWidth {
               totalWidth = max(totalWidth, lineWidth)
               totalHeight += lineHeight + spacing
               lineWidth = 0; lineHeight = 0
           }
           lineWidth += sz.width + spacing
           lineHeight = max(lineHeight, sz.height)
       }
       totalWidth = max(totalWidth, lineWidth)
       totalHeight += lineHeight
       return CGSize(width: totalWidth, height: totalHeight)
    }
    func placeSubviews(
        in bounds:      CGRect,
        proposal:       ProposedViewSize,
        subviews:       Subviews,
        cache:          inout Void
    ) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for subview in subviews {
            let sz = subview.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX {
                x = bounds.minX; y += lineHeight + spacing; lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: sz.width, height: sz.height))
            x += sz.width + spacing
            lineHeight = max(lineHeight, sz.height)
        }
    }
}
