import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = UITabBarItem(
            title: "AI Tools",
            image: UIImage(systemName: "brain"),
            tag: 0)

        let aboutNav = UINavigationController(rootViewController: AboutViewController())
        aboutNav.tabBarItem = UITabBarItem(
            title: "Tác giả",
            image: UIImage(systemName: "person.2.fill"),
            tag: 1)

        let tab = UITabBarController()
        tab.viewControllers = [homeNav, aboutNav]
        tab.tabBar.tintColor = .systemBlue

        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        return true
    }
}
