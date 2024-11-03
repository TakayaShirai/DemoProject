import UIKit

// View controller for switching between different AppRootViewControllers.
class OriginViewController: UIViewController {

  // MARK: - Private Props

  private enum LocalizedString {
    static let uiScrollViewButtonTitle = String(
      localized: "AppRootViewController with UIScrollView")
    static let uiScrollViewWithGestureButtonTitle = String(
      localized: "AppRootViewController with UIScrollView and Gesture")
    static let animationButtonTitle = String(localized: "AppRootViewController with Animation")
  }

  private lazy var uiScrollViewButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(LocalizedString.uiScrollViewButtonTitle, for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.addTarget(self, action: #selector(uiScrollViewButtonDidReceiveTap), for: .touchUpInside)
    return button
  }()

  private lazy var uiScrollViewWithGestureButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(LocalizedString.uiScrollViewWithGestureButtonTitle, for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.addTarget(
      self, action: #selector(uiScrollViewWithGestureButtonDidReceiveTap), for: .touchUpInside)
    return button
  }()

  private lazy var animationButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(LocalizedString.animationButtonTitle, for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.addTarget(self, action: #selector(animationButtonDidReceiveTap), for: .touchUpInside)
    return button
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  // MARK: - Private API

  private func setUpSubviews() {
    view.addSubview(uiScrollViewButton)
    view.addSubview(uiScrollViewWithGestureButton)
    view.addSubview(animationButton)

    view.backgroundColor = .systemBackground

    let layoutGuide = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      uiScrollViewButton.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
      uiScrollViewButton.bottomAnchor.constraint(equalTo: uiScrollViewWithGestureButton.topAnchor),

      uiScrollViewWithGestureButton.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
      uiScrollViewWithGestureButton.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),

      animationButton.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
      animationButton.topAnchor.constraint(equalTo: uiScrollViewWithGestureButton.bottomAnchor),
    ])
  }

  @objc
  private func uiScrollViewButtonDidReceiveTap() {
    let viewController = AppRootViewController()
    viewController.modalPresentationStyle = .formSheet
    self.present(viewController, animated: true)
  }

  @objc
  private func uiScrollViewWithGestureButtonDidReceiveTap() {
    let viewController = GestureAppRootViewController()
    viewController.modalPresentationStyle = .formSheet
    self.present(viewController, animated: true)
  }

  @objc
  private func animationButtonDidReceiveTap() {
    let viewController = AnimationAppRootViewController()
    viewController.modalPresentationStyle = .formSheet
    self.present(viewController, animated: true)
  }
}
