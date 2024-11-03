import SwiftUI
import UIKit

class GestureSampleViewController: GestureViewControllerWithSideMenuNavigationButton {

  // MARK: - Private Props

  private lazy var hostingController: UIHostingController = {
    let controller = UIHostingController(
      rootView: GestureSampleView(bodyText: bodyText, delegate: self))
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(controller)
    controller.didMove(toParent: self)
    return controller
  }()

  //MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUpNavigation()
  }

  // MARK: - Private API

  private func setUpSubviews() {
    view.addSubview(hostingController.view)

    let layoutGuide = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
    ])
  }

  private func setUpNavigation() {
    view.backgroundColor = .systemBackground

    navigationController?.navigationBar.tintColor = .black
    navigationItem.backButtonDisplayMode = .minimal
  }
}

// MARK: - Delegate

extension GestureSampleViewController: GestureSampleViewDelegate {
  func navigationButtonDidReceiveTap() {
    showSideMenu()
  }
}

// MARK: - View

struct GestureSampleView: View {

  public let bodyText: String

  public weak var delegate: GestureSampleViewDelegate?

  private enum LocalizedString {
    static let sampleViewText = String(localized: "Side Menu with UIScrollView and Gesture")
    static let navigationButtonText = String(localized: "Present Side Menu")
  }

  private enum LayoutConstant {
    static let navigationButtonCornerRadius: CGFloat = 10.0
  }

  var body: some View {
    VStack {
      SampleViewText()
      NavigationButton()
    }
    .padding()
  }

  @ViewBuilder
  private func SampleViewText() -> some View {
    Text(bodyText)
      .font(.title)
  }

  @ViewBuilder
  private func NavigationButton() -> some View {
    Button {
      delegate?.navigationButtonDidReceiveTap()
    } label: {
      Text(LocalizedString.navigationButtonText)
        .foregroundStyle(.white)
        .padding()
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstant.navigationButtonCornerRadius))
    }
  }
}

protocol GestureSampleViewDelegate: AnyObject {
  func navigationButtonDidReceiveTap()
}

#Preview {
  GestureSampleView(bodyText: "sample")
}
