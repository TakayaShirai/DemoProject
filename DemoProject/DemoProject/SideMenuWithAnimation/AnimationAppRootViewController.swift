import DrawerPresentation
import SwiftUI
import UIKit

// Implementation of SideMenu Functionality with Animation.
class AnimationAppRootViewController: UIViewController {

  // MARK: - Private properties

  private enum LocalizedString {
    static let helloText = String(localized: "Hello, World!")
  }

  private let sideMenuTransitionController = SideMenuTransitionController()

  private lazy var mainRootViewController: AnimationMainRootViewController = {
    let viewController = AnimationMainRootViewController.sharedInstance
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(viewController)
    viewController.didMove(toParent: self)
    return viewController
  }()

  private lazy var sideMenuViewController: UIViewController = AnimationSideMenuViewController()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
    sideMenuTransitionController.setUpViewControllersForSideMenuTransition(
      parentVC: self, mainVC: mainRootViewController, sideMenuVC: sideMenuViewController)
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
    sideMenuTransitionController.presentSideMenu()
  }

  @objc
  public func hideSideMenu() {
    sideMenuTransitionController.dismissSideMenu()
  }
}

// MARK: - Delegate

extension AnimationAppRootViewController: AnimationSideMenuViewDelegate {
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
