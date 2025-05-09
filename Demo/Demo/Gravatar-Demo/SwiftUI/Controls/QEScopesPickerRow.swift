import SwiftUI

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
