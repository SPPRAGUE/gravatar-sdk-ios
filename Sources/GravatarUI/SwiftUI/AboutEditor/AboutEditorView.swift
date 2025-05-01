import SwiftUI

struct AboutEditorView: View {
    @ObservedObject var model: AvatarPickerViewModel
    let fields: AboutInfoField
    @StateObject private var inputFields: AboutInputFields = .init()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .DS.Padding.double) {
                personalInfoContent()
            }
            .padding(.DS.Padding.double)
            .avatarPickerBorder(colorScheme: colorScheme, borderWidth: 1)
            .padding(.horizontal, .DS.Padding.double)
        }
    }

    @ViewBuilder
    func personalInfoContent() -> some View {
        if fields.contains(.displayName) {
            inputField(
                for: AboutInfoField.displayName.localizedName(),
                value: $inputFields.displayName
            )
        }
        if fields.contains(.aboutMe) {
            inputField(
                for: AboutInfoField.aboutMe.localizedName(),
                value: $inputFields.aboutMe,
                isLarge: true
            )
        }
        if fields.contains(.pronunciation) {
            inputField(
                for: AboutInfoField.pronunciation.localizedName(),
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

    private func inputField(
        for title: String,
        footerText: String? = nil,
        value: Binding<String>,
        isLarge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.single) {
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            if isLarge {
                TextEditor(text: value)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                    .padding(.DS.Padding.split)
                    .shape(
                        RoundedRectangle(cornerRadius: 2),
                        borderColor: Color(uiColor: .label.withAlphaComponent(0.15)),
                        borderWidth: 1
                    )
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
            } else {
                TextField(
                    "",
                    text: value
                )
                .lineLimit(isLarge ? 4 : 1)
                .frame(maxWidth: .infinity)
                .padding(.DS.Padding.split)
                .shape(
                    RoundedRectangle(cornerRadius: 2),
                    borderColor: Color(uiColor: .label.withAlphaComponent(0.15)),
                    borderWidth: 1
                )
            }

            if let footerText {
                Text(footerText)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate class AboutInputFields: ObservableObject {
    @Published var displayName: String = ""
    @Published var aboutMe: String = ""
    @Published var pronunciation: String = ""
    @Published var pronouns: String = ""
    @Published var location: String = ""

    func convertToUpdatedFields(for fields: AboutInfoField) -> UpdatedFields {
        UpdatedFields(
            displayName: fields.contains(.aboutMe) ? aboutMe : nil,
            aboutMe: fields.contains(.aboutMe) ? aboutMe : nil,
            pronunciation: fields.contains(.pronunciation) ? pronunciation : nil,
            pronouns: fields.contains(.pronouns) ? pronouns : nil,
            location: fields.contains(.location) ? location : nil
        )
    }
}

struct UpdatedFields {
    var displayName: String? = nil
    var aboutMe: String? = nil
    var pronunciation: String? = nil
    var pronouns: String? = nil
    var location: String? = nil
}

#Preview {
    AboutEditorView(model: .init(avatarImageModels: []), fields: .all)
}
