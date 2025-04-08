import SwiftUI
import GravatarUI

struct ProfileTypePickerRow: View {
    enum Options: String, CaseIterable, Identifiable {
        var id: String {
            rawValue
        }

        case standard
        case large
        case summary
        case largeSummary
    }

    @Binding var options: Options

    var body: some View {
        HStack {
            Text("Style")
            Spacer()
            Picker("Style", selection: $options) {
                ForEach(Options.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: options) { _ in
            }
        }
    }
}

#Preview {
    ProfileTypePickerRow(options: .constant(.standard))
}
