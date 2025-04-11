import SwiftUI
import UIKit

public typealias CustomImageEditorControllerFactory = (UIImage, @escaping @Sendable (UIImage) -> Void) -> CustomImageEditorController

final class QuickEditorViewController: UIViewController, ModalPresentationWithIntrinsicSize {
    private typealias CustomFactory = ImageEditorBlock<CustomImageEditorControllerRepresentable>?

    let email: Email
    let scope: QuickEditorScope
    let token: String?
    let configuration: QuickEditorConfiguration
    let onAvatarUpdated: (() -> Void)?
    let onDismiss: (() -> Void)?

    private lazy var isPresented: Binding<Bool> = Binding {
        true
    } set: { isPresented in
        Task { @MainActor in
            guard !isPresented else { return }
            self.dismiss(animated: true)
            self.onDismiss?()
        }
    }

    var verticalSizeClass: UserInterfaceSizeClass?
    var sheetHeight: CGFloat = QEModalPresentationConstants.bottomSheetEstimatedHeight
    var contentLayoutWithPresentation: AvatarPickerContentLayout {
        switch scope {
        case .avatarPicker(let config):
            config.contentLayout
        }
    }

    private lazy var rootView: QuickEditor = {
        let factory: CustomFactory = if let customFactory = configuration.customImageEditorFactory {
            { image, callback in
                CustomImageEditorControllerRepresentable(
                    controllerFactory: customFactory,
                    inputImage: image,
                    editingDidFinish: callback
                )
            }
        } else {
            nil as ImageEditorBlock<CustomImageEditorControllerRepresentable>?
        }

        return QuickEditor(
            email: email,
            scope: scope.scopeType,
            token: token,
            isPresented: isPresented,
            customImageEditor: factory,
            contentLayoutProvider: contentLayoutWithPresentation,
            avatarUpdatedHandler: onAvatarUpdated
        )
    }()

    private lazy var quickEditor: InnerHeightUIHostingController = .init(
        rootView: rootView,
        onHeightChange: { [weak self] newHeight in
            guard let self else { return }
            if self.shouldAcceptHeight(newHeight) {
                self.sheetHeight = newHeight
            }
            self.updateDetents()
        },
        onVerticalSizeClassChange: { [weak self] verticalSizeClass in
            guard let self, verticalSizeClass != nil else { return }
            self.verticalSizeClass = verticalSizeClass
            self.updateDetents()
        }
    )

    init(
        email: Email,
        scope: QuickEditorScope,
        configuration: QuickEditorConfiguration? = nil,
        token: String? = nil,
        onAvatarUpdated: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.email = email
        self.scope = scope
        self.configuration = configuration ?? .default
        self.token = token
        self.onDismiss = onDismiss
        self.onAvatarUpdated = onAvatarUpdated
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        quickEditor.willMove(toParent: self)
        addChild(quickEditor)
        view.addSubview(quickEditor.view)
        quickEditor.didMove(toParent: self)
        quickEditor.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quickEditor.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickEditor.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickEditor.view.topAnchor.constraint(equalTo: view.topAnchor),
            quickEditor.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        updateDetents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController != nil {
            assertionFailure("This View Controller should be presented modally, without wrapping it in a Navigation Controller.")
        }
    }

    func updateDetents() {
        if let sheet = sheetPresentationController {
            sheet.animateChanges {
                sheet.detents = QEDetent.detents(
                    for: contentLayoutWithPresentation,
                    intrinsicHeight: sheetHeight,
                    verticalSizeClass: verticalSizeClass
                ).map()
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = !contentLayoutWithPresentation.prioritizeScrollOverResize
        }
    }
}

/// UIHostingController subclass which reads the InnerHeightPreferenceKey changes
private class InnerHeightUIHostingController: UIHostingController<AnyView> {
    let onHeightChange: (CGFloat) -> Void
    let onVerticalSizeClassChange: (UserInterfaceSizeClass?) -> Void

    init(rootView: some View, onHeightChange: @escaping (CGFloat) -> Void, onVerticalSizeClassChange: @escaping (UserInterfaceSizeClass?) -> Void) {
        self.onHeightChange = onHeightChange
        self.onVerticalSizeClassChange = onVerticalSizeClassChange
        weak var weakSelf: InnerHeightUIHostingController?
        super.init(rootView: AnyView(
            rootView
                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                    Task { @MainActor in
                        weakSelf?._innerSwiftUIContentHeight = newHeight
                    }
                }
                .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                    Task { @MainActor in
                        weakSelf?._innerVerticalSizeClass = newSizeClass
                    }
                }
        ))
        weakSelf = self
    }

    @available(*, unavailable)
    @objc
    dynamic required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private var _innerSwiftUIContentHeight: CGFloat = 0 {
        didSet { onHeightChange(_innerSwiftUIContentHeight) }
    }

    private var _innerVerticalSizeClass: UserInterfaceSizeClass? = nil {
        didSet { onVerticalSizeClassChange(_innerVerticalSizeClass) }
    }
}

public struct QuickEditorPresenter {
    let email: Email
    let scope: QuickEditorScope
    let configuration: QuickEditorConfiguration
    let token: String?

    public init(
        email: Email,
        scope: QuickEditorScope,
        configuration: QuickEditorConfiguration? = nil,
        token: String? = nil
    ) {
        self.email = email
        self.scope = scope
        self.configuration = configuration ?? .default
        self.token = token
    }

    @MainActor
    public func present(
        in parent: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        onAvatarUpdated: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let quickEditor = QuickEditorViewController(
            email: email,
            scope: scope,
            configuration: configuration,
            token: token,
            onAvatarUpdated: onAvatarUpdated,
            onDismiss: onDismiss
        )

        quickEditor.overrideUserInterfaceStyle = configuration.interfaceStyle
        parent.present(quickEditor, animated: animated, completion: completion)
    }
}

@MainActor
public protocol CustomImageEditorController: UIViewController {
    var inputImage: UIImage { get }
    var editingDidFinish: @Sendable (UIImage) -> Void { get }

    init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?,
        inputImage: UIImage,
        editingDidFinish: @Sendable @escaping (UIImage) -> Void
    )
}

private struct CustomImageEditorControllerRepresentable: UIViewControllerRepresentable, ImageEditorView {
    var inputImage: UIImage
    var editingDidFinish: @Sendable (UIImage) -> Void

    let controllerFactory: CustomImageEditorControllerFactory

    init(
        controllerFactory: @escaping CustomImageEditorControllerFactory,
        inputImage: UIImage,
        editingDidFinish: @escaping @Sendable (UIImage) -> Void
    ) {
        self.controllerFactory = controllerFactory
        self.inputImage = inputImage
        self.editingDidFinish = editingDidFinish
    }

    func makeUIViewController(context: Context) -> UIViewController {
        controllerFactory(inputImage, editingDidFinish)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
