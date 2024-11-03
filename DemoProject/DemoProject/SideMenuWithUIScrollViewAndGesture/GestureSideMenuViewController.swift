import SwiftUI

class GestureSideMenuViewController: UIViewController {

  // MARK: - Public Props

  public weak var sideMenuViewDelegate: GestureSideMenuViewDelegate?

  // MARK: - Private Props

  private lazy var hostingController: UIHostingController = {
    let controller = UIHostingController(
      rootView: GestureSideMenuView(delegate: sideMenuViewDelegate))
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(controller)
    controller.didMove(toParent: self)
    return controller
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  // MARK: - Private API

  private func setUpSubviews() {
    view.backgroundColor = .systemBackground
    view.addSubview(hostingController.view)

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: - View

struct GestureSideMenuView: View {

  public weak var delegate: GestureSideMenuViewDelegate?

  private enum LayoutConstant {
    static let navigationButtonCornerRadius: CGFloat = 10.0
  }

  private enum LocalizedString {
    static let sideMenuText = String(localized: "Side Menu View")
    static let navigationButtonText = String(localized: "Tap here")
  }

  var body: some View {
    VStack {
      SideMenuText()
      NavigationButton()
    }
    .padding()
  }

  @ViewBuilder
  private func SideMenuText() -> some View {
    Text(LocalizedString.sideMenuText)
      .font(.headline)
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

protocol GestureSideMenuViewDelegate: AnyObject {
  func navigationButtonDidReceiveTap()
}

#Preview {
  GestureSideMenuView()
}
