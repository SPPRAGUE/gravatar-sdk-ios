import SwiftUI
import GravatarUI

struct DemoProfileView: View {
    @AppStorage("pickerEmail") private var email: String = ""
    @State private var selectedScheme: UIUserInterfaceStyle = .unspecified
    @State private var profileConfiguration: ProfileViewConfiguration = .standard().customize(delegate: nil)
    @State private var selectedProfileType: ProfileTypePickerRow.Options = .standard
    @State private var profile: Profile?
    @State private var safariURL: IdentifiableURL?
    @ObservedObject private var profileDelegate: ProfileDelegate = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                ProfileViewRepresentable(
                    configuration: $profileConfiguration,
                    oneTimeAvatarForceRefresh: .constant(false)
                )
                .id(profileConfiguration.profileStyle)
                Divider()
                ProfileTypePickerRow(options: $selectedProfileType)
                Divider()
                QEColorSchemePickerRow(selectedScheme: $selectedScheme)
                Divider()
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .onChange(of: selectedProfileType) { newValue in
            guard let profile else {
                requestProfile()
                return
            }
            var newConfig: ProfileViewConfiguration
            switch newValue {
            case .standard:
                newConfig = .standard(model: profile, palette: paletteType)
            case .large:
                newConfig = .large(model: profile, palette: paletteType)
            case .summary:
                newConfig = .summary(model: profile, palette: paletteType)
            case .largeSummary:
                newConfig = .largeSummary(model: profile, palette: paletteType)
            }
            newConfig.avatarIdentifier = profile.avatarIdentifier
            newConfig = newConfig.customize(delegate: profileDelegate)
            self.profileConfiguration = newConfig
        }
        .onChange(of: email) { newValue in
            requestProfile()
        }
        .onAppear() {
            self.profileDelegate.didTapOnProfile = { url in
                self.safariURL = IdentifiableURL(url: url)
            }
            self.profileDelegate.didTapOnAccountButton = { accountModel in
                self.safariURL = IdentifiableURL(url: accountModel?.accountURL)
            }
            self.profileConfiguration.delegate = self.profileDelegate
            requestProfile()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $safariURL) { identifiableURL in
            SafariView(url: identifiableURL.url)
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(ColorScheme(selectedScheme))
        }
        .environment(\.colorScheme, ColorScheme(selectedScheme) ?? .light)
    }

    private func requestProfile() {
        Task {
            let service = ProfileService()
            startLoading()
            let profile = try await service.fetch(with: .email(email))
            self.profile = profile
            stopLoading()
            var newConfig = self.profileConfiguration
            newConfig.avatarIdentifier = profile.avatarIdentifier
            newConfig.model = profile
            newConfig.summaryModel = profile
            self.profileConfiguration = newConfig
        }
    }
    
    private func startLoading() {
        var newConfig = self.profileConfiguration
        newConfig.isLoading = true
        self.profileConfiguration = newConfig
    }
    
    private func stopLoading() {
        var newConfig = self.profileConfiguration
        newConfig.isLoading = false
        self.profileConfiguration = newConfig
    }
    
    private var paletteType: PaletteType {
        switch selectedScheme {
        case .unspecified:
                .system
        case .light:
                .light
        case .dark:
                .dark
        @unknown default:
                .system
        }
    }
}

fileprivate class ProfileDelegate: NSObject, ObservableObject, ProfileViewDelegate {
    var didTapOnProfile: ((URL?) -> ())?
    var didTapOnAccountButton:  ((GravatarUI.AccountModel?) -> ())?
    
    init(didTapOnProfile: ( (URL?) -> Void)? = nil, didTapOnAccountButton: ( (GravatarUI.AccountModel?) -> Void)? = nil) {
        self.didTapOnProfile = didTapOnProfile
        self.didTapOnAccountButton = didTapOnAccountButton
    }
    
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnProfileButtonWithStyle style: GravatarUI.ProfileButtonStyle, profileURL: URL?) {
        didTapOnProfile?(profileURL)
    }
    
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAccountButtonWithModel accountModel: any GravatarUI.AccountModel) {
        didTapOnAccountButton?(accountModel)
    }
    
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAvatarWithID avatarID: Gravatar.AvatarIdentifier?) {
        // no op.
    }
}

fileprivate extension ProfileViewConfiguration {
    func customize(delegate: ProfileViewDelegate?) -> ProfileViewConfiguration {
        var config = self
        config.avatarConfiguration.activityIndicatorType = .activity
        config.delegate = delegate
        return config
    }
}

#Preview {
    DemoProfileView()
}

struct IdentifiableURL: Identifiable {
    let url: URL

    init?(url: URL?) { // for convenience
        guard let url else { return nil }
        self.url = url
    }

    public var id: String {
        url.absoluteString
    }
}
