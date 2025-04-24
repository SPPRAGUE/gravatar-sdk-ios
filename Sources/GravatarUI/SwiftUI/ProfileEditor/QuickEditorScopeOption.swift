public struct QuickEditorScopeOption {
    let avatarPickerConfig: AvatarPickerConfiguration?
    let aboutEditorConfig: AboutEditorConfiguration?
    let scope: QuickEditorScopeType

    init(
        scope: QuickEditorScopeType,
        avatarPickerConfig: AvatarPickerConfiguration? = nil,
        aboutEditorConfig: AboutEditorConfiguration? = nil
    ) {
        self.avatarPickerConfig = avatarPickerConfig
        self.aboutEditorConfig = aboutEditorConfig
        self.scope = scope
    }

    public static func avatarPicker(
        _ config: AvatarPickerConfiguration
    ) -> Self {
        .init(
            scope: .avatarPicker,
            avatarPickerConfig: config
        )
    }

    public static func aboutEditor(
        _ config: AboutEditorConfiguration = .init()
    ) -> Self {
        .init(
            scope: .aboutInfoEditor,
            aboutEditorConfig: config
        )
    }
}
