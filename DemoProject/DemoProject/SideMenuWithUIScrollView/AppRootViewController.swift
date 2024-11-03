import SwiftUI
import UIKit

// Current Implementation of SideMenu Functionality.
class AppRootViewController: UIViewController {

  // MARK: - Public properties

  public var isSideMenuScrollable: Bool = true {
    didSet {
      scrollView.isScrollEnabled = isSideMenuScrollable
    }
  }

  // MARK: - Private properties

  private enum LocalizedString {
    static let helloText = String(localized: "Hello, World!")
  }

  private lazy var mainRootViewController: MainRootViewController = {
    let viewController = MainRootViewController.sharedInstance
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(viewController)
    viewController.didMove(toParent: self)
    return viewController
  }()

  private lazy var sideMenuViewController: SideMenuViewController = {
    let viewController = SideMenuViewController()
    viewController.sideMenuViewDelegate = self
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(viewController)
    viewController.didMove(toParent: self)
    return viewController
  }()

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    return scrollView
  }()

  private let overlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .gray
    view.alpha = 0.0
    return view
  }()

  private let contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var backGroundTapGestureRecognizer: UITapGestureRecognizer = {
    var gestureRecognizer = UITapGestureRecognizer()
    gestureRecognizer.addTarget(self, action: #selector(overlayViewDidReceiveTap))
    return gestureRecognizer
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  // MARK: - Private API

  private func setUpSubviews() {
    contentView.addSubview(mainRootViewController.view)
    contentView.addSubview(overlayView)
    contentView.addSubview(sideMenuViewController.view)

    scrollView.addSubview(contentView)

    view.addSubview(scrollView)

    view.backgroundColor = .systemBackground

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.heightAnchor.constraint(equalTo: view.heightAnchor),

      sideMenuViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
      sideMenuViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      sideMenuViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      sideMenuViewController.view.trailingAnchor.constraint(
        equalTo: mainRootViewController.view.leadingAnchor),

      overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
      overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      mainRootViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
      mainRootViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      mainRootViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      mainRootViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])

    overlayView.addGestureRecognizer(backGroundTapGestureRecognizer)

    scrollView.delegate = self

    Task {
      hideSideMenu(animated: false)
    }
  }

  @objc
  private func overlayViewDidReceiveTap() {
    // Without this wrap, animated becomes false when tapping overlay view.
    hideSideMenu()
  }

  // MARK: - Public API

  public func showSideMenu() {
    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }

  @objc
  public func hideSideMenu(animated: Bool = true) {
    scrollView.setContentOffset(
      CGPoint(x: sideMenuViewController.view.frame.width, y: 0), animated: animated)
  }
}

// MARK: - Delegate

extension AppRootViewController: SideMenuViewDelegate {
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

extension AppRootViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.x
    let sideMenuWidth = sideMenuViewController.view.frame.width
    let transparency = max(0, min(1, 1 - (offset / sideMenuWidth)))

    overlayView.alpha = transparency
    overlayView.layer.opacity = Float(transparency * 0.5)
  }

  func scrollViewWillEndDragging(
    _ scrollView: UIScrollView, withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>
  ) {
    if velocity.x > 0 {
      // When swiped left, hide the side menu.
      hideSideMenu()
    } else {
      // When swiped right, show the side menu.
      showSideMenu()
    }
  }
}

// MARK: Initial View Controller Presented in UITabBarController

class ViewControllerWithSideMenuNavigationButton: UIViewController {

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

      // Avoid assigning OriginViewController as the viewController.
      if let viewController = viewController as? AppRootViewController {
        return viewController
      }
    }
    return viewController
  }

  @objc
  public func showSideMenu() {
    guard let rootViewController = self.rootViewController as? AppRootViewController else { return }
    rootViewController.showSideMenu()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let rootViewController = self.rootViewController as? AppRootViewController else { return }
    rootViewController.hideSideMenu(animated: false)
    rootViewController.isSideMenuScrollable = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard let rootViewController = self.rootViewController as? AppRootViewController else { return }
    rootViewController.isSideMenuScrollable = false
  }
}
