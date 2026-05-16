import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let root = MainTabBarController()
        window?.rootViewController = root
        window?.backgroundColor = .black
        window?.makeKeyAndVisible()
        return true
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard
            let urlStr = shortcutItem.userInfo?["url"] as? String,
            let root   = window?.rootViewController as? MainTabBarController
        else { completionHandler(false); return }

        root.handleQuickAction(url: urlStr)
        completionHandler(true)
    }
}
