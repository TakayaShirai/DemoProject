import SwiftUI
import UIKit

// Implementation of SideMenu Functionality with Added PanGesture.
class GestureAppRootViewController: UIViewController {

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

  private lazy var mainRootViewController: GestureMainRootViewController = {
    let viewController = GestureMainRootViewController.sharedInstance
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(viewController)
    viewController.didMove(toParent: self)
    return viewController
  }()

  private lazy var sideMenuViewController: GestureSideMenuViewController = {
    let viewController = GestureSideMenuViewController()
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

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    return stackView
  }()

  private let overlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .gray
    view.alpha = 0.0
    return view
  }()

  private lazy var backGroundTapGestureRecognizer: UITapGestureRecognizer = {
    var gestureRecognizer = UITapGestureRecognizer()
    gestureRecognizer.addTarget(self, action: #selector(overlayViewDidTap))
    return gestureRecognizer
  }()

  private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let gestureRecognizer = UIPanGestureRecognizer(
      target: self, action: #selector(handlePanGesture(_:)))
    return gestureRecognizer
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  // MARK: - Private API

  private func setUpSubviews() {
    stackView.addArrangedSubview(sideMenuViewController.view)
    stackView.addArrangedSubview(mainRootViewController.view)
    scrollView.addSubview(stackView)
    view.addSubview(scrollView)
    view.addSubview(overlayView)
    view.backgroundColor = .systemBackground

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

      sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      mainRootViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      mainRootViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mainRootViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),

      overlayView.topAnchor.constraint(equalTo: mainRootViewController.view.topAnchor),
      overlayView.leadingAnchor.constraint(equalTo: mainRootViewController.view.leadingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: mainRootViewController.view.bottomAnchor),
      overlayView.trailingAnchor.constraint(equalTo: mainRootViewController.view.trailingAnchor),
    ])

    overlayView.addGestureRecognizer(backGroundTapGestureRecognizer)
    overlayView.addGestureRecognizer(panGestureRecognizer)

    scrollView.delegate = self

    Task {
      hideSideMenu(animated: false)
    }
  }

  @objc
  private func overlayViewDidTap() {
    // Without this wrap, animated becomes false when tapping overlay view.
    hideSideMenu()
  }

  @objc
  private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    let sideMenuWidth = sideMenuViewController.view.frame.width

    switch gesture.state {
    case .changed:
      let newOffsetX = min(
        sideMenuViewController.view.frame.width, max(0, scrollView.contentOffset.x - translation.x))
      scrollView.contentOffset.x = newOffsetX
      gesture.setTranslation(.zero, in: view)

      let progress = 1.0 - newOffsetX / sideMenuWidth
      overlayView.alpha = progress
      overlayView.layer.opacity = Float(progress * 0.5)

    case .ended:
      let velocity = gesture.velocity(in: view)
      let threshold: CGFloat = 0

      if velocity.x < threshold {
        hideSideMenu()
      } else {
        showSideMenu()
      }

    default:
      break
    }
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

extension GestureAppRootViewController: GestureSideMenuViewDelegate {
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

extension GestureAppRootViewController: UIScrollViewDelegate {
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
      hideSideMenu()
    } else {
      showSideMenu()
    }
  }
}

// MARK: Initial View Controller Presented in UITabBarController

class GestureViewControllerWithSideMenuNavigationButton: UIViewController {

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
    if let viewController = viewController as? GestureAppRootViewController {
      return viewController
    }

    return viewController
  }

  @objc
  public func showSideMenu() {
    guard let rootViewController = self.rootViewController as? GestureAppRootViewController else {
      return
    }
    rootViewController.showSideMenu()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let rootViewController = self.rootViewController as? GestureAppRootViewController else {
      return
    }
    rootViewController.hideSideMenu(animated: false)
    rootViewController.isSideMenuScrollable = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard let rootViewController = self.rootViewController as? GestureAppRootViewController else {
      return
    }
    rootViewController.isSideMenuScrollable = false
  }
}
