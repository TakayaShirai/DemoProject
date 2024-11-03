import SwiftUI
import UIKit

class AnimationMainRootViewController: UITabBarController {

  // MARK: - Public Props

  public static var sharedInstance = AnimationMainRootViewController()

  // MARK: - Private Props

  private enum TabBarItemTag: Int {
    case home
    case search
    case communities
    case notifications
    case messages
  }

  private enum LocalizedString {
    static let homeText = String(localized: "Home")
    static let searchText = String(localized: "Search")
    static let communitiesText = String(localized: "Communities")
    static let notificationsText = String(localized: "Notifications")
    static let messagesText = String(localized: "Messages")
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpTabBar()
    setUpSubviews()
  }

  // MARK: - Private API

  private func setUpTabBar() {
    tabBar.backgroundColor = .systemBackground
  }

  private func setUpSubviews() {
    let homeNavigationController = UINavigationController(
      rootViewController: AnimationSampleViewController(bodyText: LocalizedString.homeText))
    homeNavigationController.tabBarItem = UITabBarItem(
      title: "", image: UIImage(systemName: "house"), tag: TabBarItemTag.home.rawValue)

    let searchViewController = UINavigationController(
      rootViewController: AnimationSampleViewController(bodyText: LocalizedString.searchText))
    searchViewController.tabBarItem = UITabBarItem(
      title: "", image: UIImage(systemName: "magnifyingglass"), tag: TabBarItemTag.search.rawValue)

    let communitiesViewController = UINavigationController(
      rootViewController: AnimationSampleViewController(bodyText: LocalizedString.communitiesText))
    communitiesViewController.tabBarItem = UITabBarItem(
      title: "", image: UIImage(systemName: "person.2"), tag: TabBarItemTag.communities.rawValue)

    let notificationsViewController = UINavigationController(
      rootViewController: AnimationSampleViewController(bodyText: LocalizedString.notificationsText)
    )
    notificationsViewController.tabBarItem = UITabBarItem(
      title: "", image: UIImage(systemName: "bell"), tag: TabBarItemTag.notifications.rawValue)

    let messagesViewController = UINavigationController(
      rootViewController: AnimationSampleViewController(bodyText: LocalizedString.messagesText))
    messagesViewController.tabBarItem = UITabBarItem(
      title: "", image: UIImage(systemName: "envelope"), tag: TabBarItemTag.messages.rawValue)

    viewControllers = [
      homeNavigationController, searchViewController, communitiesViewController,
      notificationsViewController, messagesViewController,
    ]
  }
}
