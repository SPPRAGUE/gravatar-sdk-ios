import SwiftUI

/// A UIView wrapper that calculates the intrinsicContentSize based on the compressed height of its child UIView.
class IntrinsicHeightView<ContentView: UIView>: UIView {
    var contentView: ContentView

    init(contentView: ContentView) {
        self.contentView = contentView
        super.init(frame: .zero)
        backgroundColor = .clear
        // Prevent the view to grow more than its intrinsic size.
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        addSubview(contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var contentHeight: CGFloat = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        .init(
            // We don't have a preferred size for width, let the layout system decide
            // by passing `UIView.noIntrinsicMetric`.
            width: UIView.noIntrinsicMetric,
            height: contentHeight
        )
    }

    // Calculate the height everytime the frame changes based on the compressed size of the `contentView`.
    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }

            contentView.frame = self.bounds
            contentView.layoutIfNeeded()

            // Use `UIView.layoutFittingCompressedSize` to obtain a view that is as small as possible in height.
            let targetSize = CGSize(width: frame.width, height: UIView.layoutFittingCompressedSize.height)

            contentHeight = contentView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
        }
    }
}
