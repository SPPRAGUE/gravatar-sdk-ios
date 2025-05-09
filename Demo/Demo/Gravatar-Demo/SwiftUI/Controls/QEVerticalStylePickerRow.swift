import SwiftUI
import GravatarUI

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
