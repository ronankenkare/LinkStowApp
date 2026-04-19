//
//  MainView.swift
//  LinkStow
//
//  Created by Ronan Kenkare on 8/4/25.
//

import SwiftUI
import SwiftData
import UIKit

let DEVICE_CORNER_RADIUS: CGFloat = 38
let TOP_SAFE_AREA_HEIGHT: CGFloat = 40

let PADDING: CGFloat = 16   

let MAIN_BUTTON_CORNER_RADIUS: CGFloat = DEVICE_CORNER_RADIUS - PADDING
let MAIN_BUTTON_HEIGHT: CGFloat = MAIN_BUTTON_CORNER_RADIUS*2

let GROUP_CORNER_RADIUS: CGFloat = MAIN_BUTTON_CORNER_RADIUS
let GROUP_HEIGHT: CGFloat = GROUP_CORNER_RADIUS*2
let GROUP_PADDING: CGFloat = 12
let GROUP_STROKE_WIDTH: CGFloat = GROUP_PADDING/3
let GROUP_BUBBLE_SPACING: CGFloat = GROUP_PADDING - GROUP_STROKE_WIDTH
let GROUP_NOT_SELECTED_COLOR: Color = Color.gray


enum MainButtonState {
    case pasteLink
    case searchLink
    case linkNotFound
    case addLink
    case filterLink
}

enum FilterState {
    case all
    case group(GroupModel)
    case hidden
}

// MARK: - MAIN VIEW -
struct MainView: View {
    @Query(sort: \GroupModel.name) private var groupsList: [GroupModel]
    @Query(filter: #Predicate<LinkModel> { $0.isHidden == false }, sort: \LinkModel.title) private var visibleLinks: [LinkModel]
    @Query(filter: #Predicate<LinkModel> { $0.isHidden == true }, sort: \LinkModel.title) private var hiddenLinks: [LinkModel]
    
    @AppStorage("hiddenGroupActive") private var hiddenGroupActive: Bool = false    
    @AppStorage("titleLineLimit") private var titleLineLimit: Int = 3
    @AppStorage("captionLineLimit") private var captionLineLimit: Int = 2

    @FocusState private var isLinkTitleFocused: Bool
    @State private var topAreaHeight: CGFloat = 0
    @State private var additionalTopAreaHeight: CGFloat = 0
    @State private var filterGroupSelected: GroupModel? = nil
    @State private var filterHiddenSelected: Bool = false
    @State private var sortNameAscending: Bool = true
    
    // Control Area State
    @State private var groups: [GroupModel] = []
    
    @State private var mainTextField: String = ""
    @State private var mainTextFieldDisabled: Bool = false
    @State private var showMainTextFieldClearButton: Bool = false
    @State private var mainState: MainButtonState = .pasteLink

    @State private var linkTitle: String = ""
    @State private var linkDescription: String = ""
    @State private var linkFaviconImage: Data? = nil
    @State private var showLinkTitleClearButton: Bool = false
    @State private var newLink: LinkModel? = nil
    
    // Filter Area State
    @State private var filteredState: Bool = false
    @State private var filterAllSelected: Bool = false
    @State private var sortNameColor: Color = Color("GroupBackgroundSelected")
    @State private var screenWidth: CGFloat = 0
    
    @State private var isAuthenticating: Bool = false

    // Link List Area State
    @State private var qrURLString: String? = nil
    @State private var shareURLItem: ShareURLItem? = nil
    @State private var editLink: LinkModel? = nil
    @State private var linkToDelete: LinkModel? = nil

    var mainController: MainController
    var modelContext: ModelContext
    
    init(mainController: MainController, modelContext: ModelContext) {
        self.mainController = mainController
        self.modelContext = modelContext
    }



    // MARK: - BODY -
    var body: some View {
        NavigationStack {
            ZStack {
                // Link List Area below Control Area and Filter Area
                linkListArea
                // Control Area and Filter Area above Link List Area
                VStack {
                    VStack(spacing: 0) {
                        controlArea
                        filterArea
                    }
                    // Get the height of the top area (Control Area and Filter Area)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear { topAreaHeight = geometry.size.height - (PADDING*2) }
                                .onChange(of: geometry.size.height) { oldValue, newValue in
                                    withAnimation(.easeInOut) {
                                        additionalTopAreaHeight = max(0, newValue - oldValue)
                                    }
                                }
                        }
                    )
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .vertical)
            .toolbar {
                // Preferences Button
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: PreferencesView(mainController: mainController)) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
}



// MARK: - QR CODE URL ITEM -
private extension MainView {
    struct QRCodeURLItem: Identifiable {
        let id = UUID()
        let url: String
    }
    
    struct ShareURLItem: Identifiable {
        let id = UUID()
        let url: URL
    }
}



// MARK: - CONTROL AREA -
private extension MainView {

    // Control Area View
    private var controlArea: some View {
        VStack(spacing: PADDING) {
            Spacer().frame(height: TOP_SAFE_AREA_HEIGHT)
            linkStowTitleView
            mainTextFieldView
            if (mainState == .linkNotFound) {
                linkNotFoundView.transition(.opacity.combined(with: .scale))
            }
            if (mainState == .addLink) && !(mainState == .filterLink) {
                linkFoundView.transition(.opacity.combined(with: .scale))
            }
            mainButtonView
        }
        .padding(PADDING)
        .glassEffect(.regular.tint(Color("DefaultAppColor").opacity(0.8)), in: .rect(cornerRadius: DEVICE_CORNER_RADIUS))
        .sheet(item: $newLink) { link in
            LinkEditorView(
                mainController: mainController,
                link: link,
                isNew: true
            )
        }
    }

    // MARK: Link Stow Title View
    private var linkStowTitleView: some View {
       HStack(spacing: 3) {
           Text("Link")
               .font(.largeTitle).bold().foregroundColor(.white)
           Image("linkStow_icon")
               .resizable()
               .aspectRatio(contentMode: .fit)
               .frame(height: MAIN_BUTTON_HEIGHT)
           Text("tow")
               .font(.largeTitle).bold().foregroundColor(.white)
       }
    }

    // MARK: Main Text Field View
    private var mainTextFieldView: some View {
        HStack(spacing: 8) {
            TextField(mainState == .filterLink ? "Find link" : "Enter link", text: $mainTextField)
                .autocapitalization(.none)
                .onChange(of: mainTextField) { oldValue, newValue in
                    if newValue.isEmpty {
                        showMainTextFieldClearButton = false
                        if !(mainState == .filterLink) {
                            changeMainState(to: .pasteLink)
                        }
                    } else {
                        showMainTextFieldClearButton = true
                        if !mainTextFieldDisabled && !(mainState == .filterLink) {
                            changeMainState(to: .searchLink)
                        }
                    }
                    mainTextFieldDisabled = false
                }
                .keyboardType(mainState == .filterLink ? .default : .URL)
            if showMainTextFieldClearButton {
                Button(action: {
                    mainTextField = ""  
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(PADDING)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS)
                .fill(Color(.systemBackground).opacity(0.8))
        )
        .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
    }

    // MARK: Main Button View
    private var mainButtonView: some View {
        Button(action: {
            Task {
                await mainButtonPressed()
            }
        }) {
            mainButtonLabel
                .font(.headline).bold()
                .padding(PADDING)
                .frame(maxWidth: .infinity)
                .background(
                    Color(mainButtonColor)
                        .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
                )
                .foregroundStyle(Color.white)
        }
    }

    // MARK: Main Button Color
    private var mainButtonColor: Color {
        switch mainState {
        case .pasteLink:                    return Color("PasteButton")
        case .searchLink:                   return Color("SearchButton")
        case .linkNotFound:                 return Color("LinkNotFoundButton")
        case .addLink:                      return Color("AddButton")
        case .filterLink:                   return Color("FilterButton")
        }
    }

    // MARK: Main Button Label View
    private var mainButtonLabel: some View {
        ZStack {
            Text("Paste").opacity(mainState == .pasteLink ? 1 : 0)
            Text("Search").opacity(mainState == .searchLink ? 1 : 0)    
            Text("Add Link as Entered").opacity(mainState == .linkNotFound ? 1 : 0)
            Text("Add").opacity(mainState == .addLink ? 1 : 0)
            Text("Filter").opacity(mainState == .filterLink ? 1 : 0)
        }
    }

    // MARK: Main Button Pressed
    private func mainButtonPressed() async {
        switch mainState {
            case .pasteLink:
                await pasteButtonPressed()
            case .searchLink:
                await searchButtonPressed()
            case .linkNotFound:
                linkNotFoundPressed()
            case .addLink:
                addButtonPressed()
            case .filterLink:
                print("Filter link")
        }
    }

    // MARK: Paste Button Pressed
    private func pasteButtonPressed() async {
        mainTextFieldDisabled = true
        if let pastedText = UIPasteboard.general.string {
            mainTextField = pastedText
            do {
                if let verifiedURL = try await mainController.verifyLink(from: pastedText) {
                    mainTextFieldDisabled = true
                    mainTextField = verifiedURL
                    linkTitle = try await mainController.fetchWebsiteTitle(from: verifiedURL) ?? ""
                    linkDescription = try await mainController.fetchWebsiteDescription(from: verifiedURL) ?? ""
                    linkFaviconImage = try await mainController.fetchWebsiteIcon(from: verifiedURL)
                    changeMainState(to: .addLink)
                    showLinkTitleClearButton = !mainTextField.isEmpty
                } else {
                    changeMainState(to: .linkNotFound)
                }
            } catch {
                changeMainState(to: .linkNotFound)
            }
        }
    }

    private func linkNotFoundPressed() {
        addButtonPressed()
    }

    // MARK: Add Button Pressed
    private func addButtonPressed() {
        newLink = mainController.createLink(
            url: mainTextField,
            title: linkTitle,
            caption: linkDescription,
            faviconImage: linkFaviconImage
        )
        resetMainController()
    }
    
    // MARK: Search Button Pressed
    private func searchButtonPressed() async {
        do {
            if let verifiedURL = try await mainController.verifyLink(from: mainTextField) {
                mainTextField = verifiedURL
                linkTitle = try await mainController.fetchWebsiteTitle(from: verifiedURL) ?? ""
                linkDescription = try await mainController.fetchWebsiteDescription(from: verifiedURL) ?? ""
                linkFaviconImage = try await mainController.fetchWebsiteIcon(from: verifiedURL)
                changeMainState(to: .addLink)
            } else {
                changeMainState(to: .linkNotFound)
            }
        } catch {
            changeMainState(to: .linkNotFound)
        }
    }

    // MARK: Change Main State
    private func changeMainState(to newState: MainButtonState) {
        withAnimation(.easeInOut) {
            mainState = newState
        }
    }

    // MARK: Reset Main Controller
    private func resetMainController(_ filterLink: Bool = false) {
        if !filterLink {
            changeMainState(to: .pasteLink)
        }
        mainTextField = ""
        showMainTextFieldClearButton = false
        linkTitle = ""
        linkDescription = ""
        linkFaviconImage = nil
        showLinkTitleClearButton = false
    }
    
    // MARK: Link Not Found View
    private var linkNotFoundView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [.red, .orange]),
                    startPoint: .top,
                    endPoint: .bottom))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            Text("Link Not Found")
                .font(.title2).bold().foregroundColor(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.white.opacity(0.15)).shadow(radius: 8))
        .padding(.horizontal, 20)
        .frame(maxHeight: mainState == .linkNotFound ? nil : 0)
    }
    
    // MARK: Link Found View
    private var linkFoundView: some View {
        HStack(spacing: PADDING) {
            VStack(alignment: .leading, spacing: PADDING) {
                HStack(spacing: PADDING) {
                    if linkFaviconImage != nil {
                        Image(uiImage: UIImage(data: linkFaviconImage!)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SMALL_SYMBOL, height: SMALL_SYMBOL)
                            .glassEffect(.clear.interactive(), in: .circle)
                    }
                    Text(linkTitle)    
                        .font(.headline).bold()
                        .foregroundColor(.primary)
                }
                Text(linkDescription)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(PADDING)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS)
                .fill(Color(.systemBackground).opacity(0.8))
        )
        .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
    }
}



// MARK: - FILTER AREA -
private extension MainView {

    // Filter Area View
    private var filterArea: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GROUP_PADDING) {
                if(filterAllSelected || !filteredState) {
                    filterAllView()
                        .transition(.scale)
                }
                ForEach(groupsList) { group in
                    if(filterGroupSelected == group || !filteredState) {
                        groupBubbleView(group: group)
                            .transition(.scale)
                    }
                }
                if hiddenGroupActive && (filterHiddenSelected || !filteredState) {
                    filterHiddenView()
                        .transition(.scale)
                }
                if(filteredState) {
                    sortNameView()
                        .transition(.asymmetric(
                            insertion: .offset(x: screenWidth),
                            removal: .offset(x: screenWidth)
                        ))
                }
            }
            .padding(PADDING)
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        screenWidth = geometry.size.width
                    }
                    .onChange(of: geometry.size.width) { oldValue, newValue in
                        screenWidth = newValue
                    }
            }
            .fixedSize(horizontal: false, vertical: true)
        )
    }

    // MARK: Group View
    private func groupBubbleView(group: GroupModel) -> some View {
        Button(action: {
            changeFilterState(to: .group(group), selectedGroup: group)
        }) {
            groupBubble(group: group, selected: filterGroupSelected == group)
        }
        .buttonStyle(.plain)
    }

    // MARK: Filter All View
    private func filterAllView() -> some View {
        Button(action: {
            changeFilterState(to: .all)
        }) {
            filterAllBubble()
        }
    }
    
    // MARK: Filter Hidden View
    private func filterHiddenView() -> some View {
        Button(action: {
            if filterHiddenSelected {
                changeFilterState(to: .hidden)
            } else if !isAuthenticating {
                isAuthenticating = true
                Task {
                    do {
                        let result = try await authenticateUser(activation: false)
                        await MainActor.run {
                            isAuthenticating = false
                            if result { changeFilterState(to: .hidden) }
                        }
                    } catch {
                        await MainActor.run { isAuthenticating = false }
                    }
                }
            }
        }) {
            filterHiddenBubble(filterHiddenSelected: filterHiddenSelected)
        }
    }

    // MARK: Sort Name View
    private func sortNameView() -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                sortNameAscending = !sortNameAscending
            }
        }) {
            sortDirectionBubble(sortAscending: sortNameAscending, selectedColor: sortNameColor)
        }
    }

    // MARK: Change Filter State
    private func changeFilterState(to newState: FilterState, selectedGroup: GroupModel? = nil) {
        withAnimation(.easeInOut) {
            switch newState {
            case .all:
                filterAllSelected = !filterAllSelected
                filterGroupSelected = nil
                filterHiddenSelected = false
                filteredState = filterAllSelected
                sortNameAscending = true
                sortNameColor = Color("GroupBackgroundSelected")
            case .group(let selectedGroup):
                filterAllSelected = false
                filterGroupSelected = filterGroupSelected == selectedGroup ? nil : selectedGroup
                filterHiddenSelected = false
                filteredState = (filterGroupSelected == selectedGroup && !filteredState)
                sortNameAscending = true
                sortNameColor = selectedGroup.getSymbolColor()
            case .hidden:
                filterAllSelected = false
                filterGroupSelected = nil
                filterHiddenSelected = !filterHiddenSelected
                filteredState = (hiddenGroupActive && filterHiddenSelected && !filteredState)
                sortNameAscending = true
                sortNameColor = Color("GroupBackgroundSelected")
            }
            if filteredState {
                resetMainController(true)
            } else {
                resetMainController()
            }
        }
    }

    // MARK: Filter All Content View
    private func filterAllBubble() -> some View {
        ZStack {
            if filterAllSelected {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "line.3.horizontal.decrease")
                    .resizable()
                    .scaledToFit()  
            }
        }
        .padding(GROUP_PADDING)
        .frame(width: GROUP_HEIGHT, height: GROUP_HEIGHT)
        .foregroundColor(filterAllSelected ? Color.white : Color("GroupForeground"))
        .glassEffect(.regular.tint(filterAllSelected ? Color("GroupBackgroundSelected").opacity(0.8) : Color("GroupBackground").opacity(0.8)).interactive())
        .contentShape(Capsule())
    }

    // MARK: Filter Hidden Content View
    private func filterHiddenBubble(filterHiddenSelected: Bool) -> some View {
        ZStack {
            if filterHiddenSelected {
                Image(systemName: "lock.open.fill")
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

    // MARK: Sort Direction Content View
    private func sortDirectionBubble(sortAscending: Bool, selectedColor: Color) -> some View {
        ZStack {
            Image(systemName: "arrow.up")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(sortAscending ? 0 : 180))
        }
        .padding(GROUP_PADDING)
        .frame(width: GROUP_HEIGHT, height: GROUP_HEIGHT)
        .foregroundColor(Color.white)
        .glassEffect(.regular.tint(selectedColor.opacity(0.8)).interactive())
        .clipShape(Capsule())
        .contentShape(Capsule())
    }
}




// MARK: - LINK LIST AREA -
private extension MainView {

    // Link List Area
    private var linkListArea: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: additionalTopAreaHeight)
            List {
                Section {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: max(0, topAreaHeight))
                        .contentTransition(.interpolate)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .allowsHitTesting(false)
                }
                .listSectionSpacing(0)

                // MARK: Empty State Views
                if visibleLinks.isEmpty && hiddenLinks.isEmpty {
                    Section {
                        emptyStateView(
                            icon: "link",
                            title: "No Links",
                            message: "Add your first link to get started!"
                        )
                    }
                // MARK: No Links Found View
                } else if filteredLinks.isEmpty {
                    Section {
                        emptyStateView(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "No Links Found",
                            message: "No links match your current filters. Try adjusting your filters."
                        )
                    }
                // MARK: Links List View
                } else {
                    ForEach(filteredLinks, id: \.persistentModelID) { link in
                        Section {
                            Button(action: { mainController.openLink(urlString: link.url) }) {
                                HStack(spacing: PADDING) {

                                    link.viewSymbol(small: true)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(link.title)
                                            .font(.headline).bold()
                                            .foregroundColor(.primary)
                                            .lineLimit(titleLineLimit)
                                        Text(link.caption)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(captionLineLimit)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    handleDeleteButton(for: link)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    handleQRCodeButton(for: link)
                                } label: {
                                    Label("QR Code", systemImage: "qrcode")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    handleShareButton(for: link)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.green)
                                Button {
                                    handleEditButton(for: link)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                            .animation(.easeInOut, value: topAreaHeight)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .animation(.easeInOut, value: filteredLinks)
        }
        .animation(.easeInOut, value: additionalTopAreaHeight)
        .sheet(item: $editLink) { link in
            LinkEditorView(
                mainController: mainController,
                link: link,
                isNew: false
            )
        }
        .sheet(item: Binding(
            get: { qrURLString.map { QRCodeURLItem(url: $0) } },
            set: { _ in qrURLString = nil }
        )) { item in
            QRCodeView(urlString: item.url)
                .presentationDetents([.medium])
        }
        .sheet(item: $shareURLItem) { item in
            ShareSheet(activityItems: [item.url])
        }
        .alert("Delete Link", isPresented: Binding(
            get: { linkToDelete != nil },
            set: { if !$0 { linkToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                handleDeleteConfirmation(confirmed: false)
            }
            Button("Delete", role: .destructive) {
                handleDeleteConfirmation(confirmed: true)
            }
        } message: {
            if let link = linkToDelete {
                Text("Are you sure you want to delete \"\(link.title)\"? This action cannot be undone.")
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .ignoresSafeArea(edges: .vertical)
    }

    // MARK: Filtered Links
    // visibleLinks / hiddenLinks are already sorted by title and filtered by isHidden at the DB level.
    private var filteredLinks: [LinkModel] {
        var filtered = filterHiddenSelected ? hiddenLinks : visibleLinks

        if let filterGroup = filterGroupSelected {
            filtered = filtered.filter { $0.checkLinkInGroup(group: filterGroup) }
        }

        if mainState == .filterLink && !mainTextField.isEmpty {
            let searchText = mainTextField.lowercased()
            filtered = filtered.filter {
                $0.url.lowercased().contains(searchText) ||
                $0.title.lowercased().contains(searchText) ||
                $0.caption.lowercased().contains(searchText)
            }
        }

        return sortNameAscending ? filtered : filtered.reversed()
    }
    
    // MARK: Empty State View
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .frame(width: 100, height: 100)
                .glassEffect(.clear.interactive(), in: .circle)
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(PADDING)
        .background(
            RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
    
    // MARK: Swipe Action Handlers
    private func handleQRCodeButton(for link: LinkModel) {
        qrURLString = link.url
    }
    
    private func handleDeleteButton(for link: LinkModel) {
        linkToDelete = link
    }
    
    private func handleDeleteConfirmation(confirmed: Bool) {
        if confirmed, let link = linkToDelete {
            withAnimation(.easeInOut) {
                mainController.deleteLink(link: link)
            }
        }
        linkToDelete = nil
    }
    
    private func handleShareButton(for link: LinkModel) {
        if let url = URL(string: link.url) {
            shareURLItem = ShareURLItem(url: url)
        }
    }
    
    private func handleEditButton(for link: LinkModel) {
        editLink = link
    }
}

