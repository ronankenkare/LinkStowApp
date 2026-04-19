import SwiftUI

struct PreferencesView: View {

    var mainController: MainController

    @AppStorage("hiddenGroupActive") private var hiddenGroupActive: Bool = false
    @AppStorage("titleLineLimit") private var titleLineLimit: Int = 3
    @AppStorage("captionLineLimit") private var captionLineLimit: Int = 2

    @State private var toggleValue: Bool = false
    
    var body: some View {
        Form {
            demoLink
                .listSectionSpacing(.compact)
            linkAppearanceSection
            hiddenGroupSection
            helpSection
        }
        .navigationTitle("Preferences")
        .onAppear {
            toggleValue = hiddenGroupActive
        }
        .listStyle(.insetGrouped)
    }

    // MARK: Demo Link Section
    private var demoLink: some View {
        Section (header: Text("Link Appearance")) {
            HStack(spacing: PADDING) {

                Image("linkStow_icon")
                    .resizable()
                    .scaledToFill()
                    .padding(SMALL_SYMBOL/4)
                    .frame(width: SMALL_SYMBOL, height: SMALL_SYMBOL)
                    .glassEffect(.regular.tint(Color("DefaultAppColor").opacity(0.8)).interactive())
                    .contentShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    titleTextDemo
                    captionTextDemo
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: Link Appearance Section
    private var linkAppearanceSection: some View {
        Section {
            titleLineLimitStepper
            captionLineLimitStepper
        }
    }

    // MARK: Title Text Demo
    private var titleTextDemo: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<titleLineLimit, id: \.self) { _ in
                Text(String(repeating: "-", count: Int.random(in: 1...7)) + "------------------------")
                    .font(.headline).bold()
                    .foregroundColor(Color("TitleDemoColor"))
                    .background(Color("TitleDemoColor"))
                    .lineLimit(1)
                    .textSelection(.disabled)
            }
        }
    }

    // MARK: Caption Text Demo
    private var captionTextDemo: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<captionLineLimit, id: \.self) { _ in
                Text(String(repeating: "-", count: Int.random(in: 1...7)) + "------------------------")
                    .font(.subheadline)
                    .foregroundStyle(Color("CaptionDemoColor"))
                    .background(Color("CaptionDemoColor"))
                    .lineLimit(1)
                    .textSelection(.disabled)
            }
        }
    }

    // MARK: Title Line Limit Stepper
    private var titleLineLimitStepper: some View {
        Stepper("Title Line Limit: \(titleLineLimit)", value: $titleLineLimit, in: 1...5)
            .onChange(of: titleLineLimit) { oldValue, newValue in
                titleLineLimit = newValue
            }
    }

    // MARK: Caption Line Limit Stepper
    private var captionLineLimitStepper: some View {
        Stepper("Caption Line Limit: \(captionLineLimit)", value: $captionLineLimit, in: 1...5)
            .onChange(of: captionLineLimit) { oldValue, newValue in
                captionLineLimit = newValue
            }
    }

    // MARK: Hidden Group Section   
    private var hiddenGroupSection: some View {
        Section (header: Text("Hidden Group")) {
            Toggle("Hidden Group", isOn: $toggleValue)
                .onChange(of: toggleValue) { oldValue, newValue in
                    // Only authenticate if value is actually changing
                    if newValue != hiddenGroupActive {
                        if newValue {
                            // Turning on requires authentication
                            Task {
                                do {
                                    let result = try await authenticateUser(activation: true)
                                    if result {
                                        hiddenGroupActive = newValue
                                    } else {
                                        // Authentication failed, revert toggle
                                        await MainActor.run {
                                            toggleValue = oldValue
                                        }
                                    }
                                } catch {
                                    // Authentication error, revert toggle
                                    await MainActor.run {
                                        toggleValue = oldValue
                                    }
                                }
                            }
                        } else {
                            // Turning off doesn't require authentication
                            hiddenGroupActive = false
                        }
                    }
                }
        }
    }

    // MARK: Help Section
    private var helpSection: some View {
        Section {
            Button(action: {
                mainController.openLink(urlString: "https://www.google.com")
            }) {
                HStack {    
                    Text("LinkStow Help")
                    Spacer()
                }
                .foregroundColor(Color.blue)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
