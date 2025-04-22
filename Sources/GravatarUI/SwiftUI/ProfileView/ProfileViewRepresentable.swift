import Gravatar
import SwiftUI
import UIKit

/// SwiftUI View that represents the profile view variations:``ProfileView``, ``ProfileSummaryView``, ``LargeProfileView``, ``LargeProfileSummaryView``.
public struct ProfileViewRepresentable: View {
    /// A configuration that specifies the appearance and behavior of a ProfileView and its contents.
    @Binding public var configuration: ProfileViewConfiguration
    /// Set to true to force a refresh of the avatar image.
    @Binding public var oneTimeAvatarForceRefresh: Bool

    public init(configuration: Binding<ProfileViewConfiguration>, oneTimeAvatarForceRefresh: Binding<Bool>) {
        self._configuration = configuration
        self._oneTimeAvatarForceRefresh = oneTimeAvatarForceRefresh
    }

    public var body: some View {
        ProfileViewContainer(configuration: $configuration, oneTimeAvatarForceRefresh: $oneTimeAvatarForceRefresh)
    }
}

/// Internal type to encapsulate inner types.
@MainActor
struct ProfileViewContainer: UIViewRepresentable {
    typealias ContentViewType = IntrinsicHeightView<BaseProfileView>

    @Binding var configuration: ProfileViewConfiguration
    @Binding var oneTimeAvatarForceRefresh: Bool

    init(configuration: Binding<ProfileViewConfiguration>, oneTimeAvatarForceRefresh: Binding<Bool>) {
        self._configuration = configuration
        self._oneTimeAvatarForceRefresh = oneTimeAvatarForceRefresh
    }

    class Coordinator {
        var contentView: ContentViewType?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ContentViewType {
        guard let view = configuration.makeContentView() as? BaseProfileView else {
            assertionFailure("Unsupported content view type")
            return IntrinsicHeightView(contentView: ProfileView())
        }
        let containerView = IntrinsicHeightView(contentView: view)
        context.coordinator.contentView = containerView
        return containerView
    }

    public func updateUIView(_ uiView: ContentViewType, context: Context) {
        uiView.contentView.configuration = configuration
        if oneTimeAvatarForceRefresh {
            let options: [ImageSettingOption] = if let existingOptions = configuration.avatarConfiguration.settingOptions {
                existingOptions + [.forceRefresh]
            } else {
                [.forceRefresh]
            }
            uiView.contentView.loadAvatar(
                with: configuration.avatarIdentifier,
                placeholder: configuration.avatarConfiguration.placeholder,
                rating:
                configuration.avatarConfiguration.rating,
                defaultAvatarOption: configuration.avatarConfiguration.defaultAvatarOption,
                options: options
            )
            // Reset the flag so it doesn’t repeat
            DispatchQueue.main.async {
                oneTimeAvatarForceRefresh = false
            }
        }
    }
}
