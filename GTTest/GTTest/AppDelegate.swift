//
//  AppDelegate.swift
//  GTTest
//
//  Created by yutong on 2024/2/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var friendsVM = FriendsViewModel()
    static var moneyVC:MoneyVC?
    static var friendVC:FriendsVC?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

