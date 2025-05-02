import SwiftUI

struct AboutEditorView: View {
    private enum Constants {
        static let primaryFont: Font = .subheadline
        static let sectionHeaderFont: Font = .subheadline.weight(.bold)
        static let footerFont: Font = .footnote
    }

    @ObservedObject var model: AvatarPickerViewModel
    let fields: AboutInfoField
    @StateObject private var inputFields: AboutInputFields = .init()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                personalInfoContent()
                Spacer().frame(height: .DS.Padding.double)
                professionalInfoContent()
            }
            .padding(.DS.Padding.double)
            .avatarPickerBorder(colorScheme: colorScheme, borderWidth: 1)
            .padding(.horizontal, .DS.Padding.double)
            Spacer().frame(height: .DS.Padding.double)
        }
        saveButton()
            .padding(.horizontal, .DS.Padding.large)
            .padding(.bottom, .DS.Padding.double)
    }

    private func saveButton() -> some View {
        Button {
            print("")
        } label: {
            CTAButtonView(Localized.saveButtonTitle)
        }
    }

    @ViewBuilder
    private func personalInfoContent() -> some View {
        if hasMultipleSections {
            sectionHeader(title: Localized.personalSectionHeaderText)
        }
        if fields.contains(.displayName) {
            inputField(
                for: AboutInfoField.displayName.localizedName(),
                value: $inputFields.displayName
            )
        }
        if fields.contains(.aboutMe) {
            inputField(
                for: AboutInfoField.aboutMe.localizedName(),
                footerText: Localized.aboutMeFooterText,
                value: $inputFields.aboutMe,
                isLarge: true
            )
        }
        if fields.contains(.pronunciation) {
            inputField(
                for: AboutInfoField.pronunciation.localizedName(),
                footerText: Localized.pronunciationFooterText,
                value: $inputFields.pronunciation
            )
        }
        if fields.contains(.pronouns) {
            inputField(
                for: AboutInfoField.pronouns.localizedName(),
                value: $inputFields.pronouns
            )
        }
        if fields.contains(.location) {
            inputField(
                for: AboutInfoField.location.localizedName(),
                value: $inputFields.location
            )
        }
    }

    @ViewBuilder
    private func professionalInfoContent() -> some View {
        if hasMultipleSections {
            sectionHeader(title: Localized.professionalSectionHeaderText)
        }
        if fields.contains(.jobTitle) {
            inputField(
                for: AboutInfoField.jobTitle.localizedName(),
                value: $inputFields.jobTitle
            )
        }
        if fields.contains(.company) {
            inputField(
                for: AboutInfoField.company.localizedName(),
                value: $inputFields.company
            )
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Constants.sectionHeaderFont)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .DS.Padding.single)
    }

    private func inputField(
        for title: String,
        footerText: String? = nil,
        value: Binding<String>,
        isLarge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.single) {
            Text(title)
                .font(Constants.primaryFont)
                .multilineTextAlignment(.leading)
            if isLarge {
                TextEditor(text: value)
                    .font(Constants.primaryFont)
                    .multilineTextAlignment(.leading)
                    .padding(.DS.Padding.split)
                    .inputBorders(colorScheme: colorScheme)
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
            } else {
                TextField(
                    "",
                    text: value
                )
                .font(Constants.primaryFont)
                .padding(.DS.Padding.split)
                .inputBorders(colorScheme: colorScheme)
            }

            if let footerText {
                Text(footerText)
                    .font(Constants.footerFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }
        }
        .padding(.vertical, .DS.Padding.single)
        .frame(maxWidth: .infinity)
    }

    private var hasMultipleSections: Bool {
        (fields.contains(.personalFields) ? 1 : 0) +
            (fields.contains(.professionalFields) ? 1 : 0) > 1
    }

    private enum Localized {
        static let aboutMeFooterText = SDKLocalizedString(
            "Profile.AboutInfoField.aboutMe.footer",
            value: "Brief description for your profile.",
            comment: "Description for the 'About me' field in the profile editing screen."
        )
        static let pronunciationFooterText = SDKLocalizedString(
            "Profile.AboutInfoField.pronunciation.footer",
            value: "Let them know how your name sounds like.",
            comment: "Description for the 'Pronunciation' field in the profile editing screen."
        )
        static let personalSectionHeaderText = SDKLocalizedString(
            "Profile.Section.Personal.header",
            value: "Personal",
            comment: "Title of the personal info section in the profile editing screen."
        )
        static let professionalSectionHeaderText = SDKLocalizedString(
            "Profile.Section.Professional.header",
            value: "Professional",
            comment: "Title of the professional/work info section in the profile editing screen."
        )
        static let saveButtonTitle = SDKLocalizedString(
            "Profile.Save.title",
            value: "Save",
            comment: "Title of the button to save changes in the profile editing screen."
        )
    }
}

private class AboutInputFields: ObservableObject {
    @Published var displayName: String = ""
    @Published var aboutMe: String = ""
    @Published var pronunciation: String = ""
    @Published var pronouns: String = ""
    @Published var location: String = ""
    @Published var jobTitle: String = ""
    @Published var company: String = ""

    func fieldsToUpdate(from fields: AboutInfoField) -> FieldsToUpdate {
        FieldsToUpdate(
            displayName: fields.contains(.aboutMe) ? aboutMe : nil,
            aboutMe: fields.contains(.aboutMe) ? aboutMe : nil,
            pronunciation: fields.contains(.pronunciation) ? pronunciation : nil,
            pronouns: fields.contains(.pronouns) ? pronouns : nil,
            location: fields.contains(.location) ? location : nil,
            jobTitle: fields.contains(.jobTitle) ? jobTitle : nil,
            company: fields.contains(.company) ? company : nil
        )
    }
}

struct FieldsToUpdate {
    var displayName: String? = nil
    var aboutMe: String? = nil
    var pronunciation: String? = nil
    var pronouns: String? = nil
    var location: String? = nil
    var jobTitle: String? = nil
    var company: String? = nil
}

extension View {
    fileprivate func inputBorders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }
}

#Preview {
    AboutEditorView(model: .init(avatarImageModels: []), fields: .all)
}

#Preview("professional") {
    AboutEditorView(model: .init(avatarImageModels: []), fields: .professionalFields)
}

#Preview("personal") {
    AboutEditorView(model: .init(avatarImageModels: []), fields: .personalFields)
}
