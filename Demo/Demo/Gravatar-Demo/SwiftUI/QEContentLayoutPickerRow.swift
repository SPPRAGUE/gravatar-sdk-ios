import SwiftUI
import GravatarUI

struct QEContentLayoutPickerRow: View {
    @Binding var contentLayoutOptions: AvatarPickerLayoutOptions

    var body: some View {
        HStack {
            Text("Content Layout")
            Spacer()
            Picker("Content Layout", selection: $contentLayoutOptions) {
                ForEach(AvatarPickerLayoutOptions.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct QEScopesPickerRow: View {
    @Binding var scope: QEScope

    var body: some View {
        HStack {
            Text("Scope")
            Spacer()
            Picker("Scope", selection: $scope) {
                ForEach(QEScope.allCases, id: \.rawValue) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct QEVerticalStylePickerRow: View {
    enum VerticalContentPresentationStyleRepresentation: String, CaseIterable, Hashable {
        case large = "Large"
        case expandableMedium = "Expandable Medium"
    }
    @Binding var verticalStyle: VerticalContentPresentationStyle
    @State var verticalStyleRep: VerticalContentPresentationStyleRepresentation = .expandableMedium

    var body: some View {
        HStack {
            Text("Vertical Style")
            Spacer()
            Picker("Vertical Style", selection: $verticalStyleRep) {
                ForEach(VerticalContentPresentationStyleRepresentation.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: verticalStyleRep) { newValue in
                switch newValue {
                    case .large:
                        verticalStyle = .large
                    case .expandableMedium:
                        verticalStyle = .expandableMedium()

                }
            }
        }
    }
}

#Preview {
    QEContentLayoutPickerRow(contentLayoutOptions: .constant(.verticalExpandable))
}
