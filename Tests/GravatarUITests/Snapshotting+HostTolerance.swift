import SnapshotTesting
import UIKit

extension Snapshotting where Value == UIView, Format == UIImage {
    /// `.image`, but tolerant of the sub-pixel differences between the macOS build a reference was recorded on and the
    /// one the CI VM runs.
    ///
    /// Views that rasterize an image — avatars, placeholders, SF Symbols — do not render identically across macOS
    /// builds, even with the Xcode version, simulator runtime, and device all matched. The CI VM images move through
    /// macOS point releases on their own schedule, so there is no host we can pin to keep an exact match, and
    /// snapshots recorded on CI cannot be recovered: the simulator sandbox silently drops the writes.
    ///
    /// Only use this for views that carry an image. Text-only views match exactly and should stay on `.image`.
    static var imageWithHostTolerance: Snapshotting {
        .image(perceptualPrecision: 0.99)
    }
}
