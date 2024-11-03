import DrawerPresentation
import SwiftUI
import UIKit

// Implementation of SideMenu Functionality with Animation.
class AnimationAppRootViewController: UIViewController {

  // MARK: - Private properties

  private enum LocalizedString {
    static let helloText = String(localized: "Hello, World!")
  }

  private let customDrawerTransitionController = CustomDrawerTransitionController()

  private lazy var mainRootViewController: AnimationMainRootViewController = {
    let viewController = AnimationMainRootViewController.sharedInstance
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(viewController)
    viewController.didMove(toParent: self)
    return viewController
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
    customDrawerTransitionController.setUpDrawer(
      mainViewController: mainRootViewController,
      sideMenuViewControllerProvider: { [weak self] in
        let sideMenuViewController = AnimationSideMenuViewController()
        sideMenuViewController.sideMenuViewDelegate = self
        return sideMenuViewController
      })
  }

  // MARK: - Private API

  private func setUpSubviews() {
    view.backgroundColor = .systemBackground

    view.addSubview(mainRootViewController.view)

    NSLayoutConstraint.activate([
      mainRootViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainRootViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mainRootViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      mainRootViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  // MARK: - Public API

  public func showSideMenu() {
    customDrawerTransitionController.showSideMenu()
  }

  @objc
  public func hideSideMenu() {
    customDrawerTransitionController.hideSideMenu()
  }
}

// MARK: - Delegate

extension AnimationAppRootViewController: AnimationSideMenuViewDelegate {
  /// The order of hiding the side menu and pushing the selected view controller impacts the animation speed.
  /// This should be addressed in a future update.
  func navigationButtonDidReceiveTap() {
    hideSideMenu()
    guard
      let selectedViewController = mainRootViewController.selectedViewController
        as? UINavigationController
    else { return }
    let controller = UIHostingController(rootView: Text(LocalizedString.helloText))
    controller.view.backgroundColor = .systemBackground
    controller.navigationItem.backButtonDisplayMode = .minimal
    selectedViewController.pushViewController(controller, animated: true)
  }
}

// MARK: Initial View Controller Presented in UITabBarController

class AnimationViewControllerWithSideMenuNavigationButton: UIViewController {

  public let bodyText: String

  init(bodyText: String) {
    self.bodyText = bodyText
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var rootViewController: UIViewController {
    var viewController = self as UIViewController
    while let parent = viewController.parent {
      viewController = parent
    }

    // Avoid assigning OriginViewController as the viewController.
    if let viewController = viewController as? AnimationAppRootViewController {
      return viewController
    }

    return viewController
  }

  @objc
  public func showSideMenu() {
    guard let rootViewController = self.rootViewController as? AnimationAppRootViewController else {
      return
    }
    rootViewController.showSideMenu()
  }
}
