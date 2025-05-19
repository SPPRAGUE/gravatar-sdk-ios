import Foundation
/// A value that describes how the Quick Editor sheet should be presented,
public struct SheetPresentationStyle: Sendable {
    public static let expandableMediumInitialFraction: CGFloat = 0.7

    enum DetentMode: Sendable {
        case large
        case expandableMedium(
            initialFraction: CGFloat = SheetPresentationStyle.expandableMediumInitialFraction,
            prioritizeScrollOverResize: Bool = false
        )
        case intrinsicHeight
        case automatic(prioritizeScrollOverResize: Bool = false)
    }

    let detentMode: DetentMode

    /// A full-height sheet presentation style.
    /// - Returns: A `SheetPresentationStyle` instance configured to present the sheet at full height.
    public static func large() -> SheetPresentationStyle {
        .init(detentMode: .large)
    }

    /// Medium height sheet that is expandable to full height. In compact height this is inactive and the sheet is displayed as full height.
    /// - initialFraction: The fractional height of the sheet in its initial state.
    /// - prioritizeScrollOverResize: A behavior that prioritizes scrolling the content of the sheet when
    /// swiping, rather than resizing it. Note that this parameter is effective only for iOS 16.4 +.
    public static func expandableMedium(
        initialFraction: CGFloat = SheetPresentationStyle.expandableMediumInitialFraction,
        prioritizeScrollOverResize: Bool = false
    ) -> SheetPresentationStyle {
        .init(
            detentMode: .expandableMedium(
                initialFraction: initialFraction,
                prioritizeScrollOverResize: prioritizeScrollOverResize
            )
        )
    }

    /// Represents a bottom sheet with intrinsic height.
    ///
    /// There are 2 size classes where this mode is inactive:
    ///  - Compact height: The sheet is displayed in full height.
    ///  - Regular width: The system ignores the intrinsic height and defaults to a full size sheet by the system.
    public static func intrinsicHeight() -> SheetPresentationStyle {
        .init(detentMode: .intrinsicHeight)
    }

    /// Applies `.intrinsicHeight` when the content height is below a defined threshold. Otherwise, applies `.expandableMedium()`.
    public static func automatic(prioritizeScrollOverResize: Bool = false) -> SheetPresentationStyle {
        .init(detentMode: .automatic(prioritizeScrollOverResize: prioritizeScrollOverResize))
    }

    var prioritizeScrollOverResize: Bool {
        switch detentMode {
        case .expandableMedium(_, let prioritizeScrollOverResize):
            prioritizeScrollOverResize
        case .automatic(let prioritizeScrollOverResize):
            prioritizeScrollOverResize
        case .intrinsicHeight:
            false
        case .large:
            false
        }
    }
}
