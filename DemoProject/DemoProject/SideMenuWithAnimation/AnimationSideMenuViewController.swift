import SwiftUI

class AnimationSideMenuViewController: UIViewController {

  public weak var sideMenuViewDelegate: AnimationSideMenuViewDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }

  private lazy var hostingController: UIHostingController = {
    let controller = UIHostingController(
      rootView: AnimationSideMenuView(delegate: sideMenuViewDelegate))
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(controller)
    controller.didMove(toParent: self)
    return controller
  }()

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

struct AnimationSideMenuView: View {

  public weak var delegate: AnimationSideMenuViewDelegate?

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

protocol AnimationSideMenuViewDelegate: AnyObject {
  func navigationButtonDidReceiveTap()
}

#Preview {
  AnimationSideMenuView()
}
