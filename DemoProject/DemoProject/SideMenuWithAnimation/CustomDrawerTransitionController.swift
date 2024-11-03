import DrawerPresentation
import UIKit

@MainActor
class CustomDrawerTransitionController: NSObject {

  private let drawerTransitionController = DrawerTransitionController()
  private weak var sideMenuViewController: UIViewController?

  public func setUpDrawer(
    mainViewController: UIViewController,
    sideMenuViewControllerProvider: @escaping () -> UIViewController
  ) {
    drawerTransitionController.addDrawerGesture(
      to: mainViewController,
      drawerViewController: { [weak self] in
        let sideMenuViewController = sideMenuViewControllerProvider()
        self?.sideMenuViewController = sideMenuViewController
        return sideMenuViewController
      }
    )
  }

  public func showSideMenu() {
    drawerTransitionController.presentRegisteredDrawer()
  }

  public func hideSideMenu(animated: Bool = true) {
    sideMenuViewController?.dismiss(animated: animated)
  }
}
