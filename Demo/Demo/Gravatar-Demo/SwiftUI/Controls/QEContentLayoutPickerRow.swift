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

#Preview {
    QEContentLayoutPickerRow(contentLayoutOptions: .constant(.verticalExpandable))
}
