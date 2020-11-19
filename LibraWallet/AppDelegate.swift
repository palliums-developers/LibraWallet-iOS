//
//  AppDelegate.swift
//  LibraWallet
//
//  Created by palliums on 2019/8/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let tabbar = BaseTabBarViewController.init()
        window?.rootViewController = tabbar
        window?.makeKeyAndVisible()
//        DataBaseManager.DBManager.creatLocalDataBase()
//        DataBaseManager.DBManager.createWalletTable()
//        DataBaseManager.DBManager.createTransferAddressListTable()
//        DataBaseManager.DBManager.createViolasTokenTable()
//        _ = DataBaseManager.DBManager.getLocalWallets()
        DataBaseManager.DBManager.initDataBase()
        IQKeyboardManager.shared.enable = true
        if let sessionData = getWalletConnectSession(), sessionData.isEmpty == false {
            WalletConnectManager.shared.reconnectToServer(sessionData: sessionData)
        }
        application.applicationIconBadgeNumber = 0
        // 添加通知
        addAlert()
        return true
    }
    func addAlert() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
//        if PUBLISH_VERSION == true {
            Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
//        }

        print("我的deviceToken：\(deviceTokenString)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = extractUserInfo(userInfo: response.notification.request.content.userInfo)
        print(content.service)
//        print(response.notification.request.content.categoryIdentifier)
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.categoryIdentifier)
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print(notification ?? "")
    }
    func extractUserInfo(userInfo: [AnyHashable : Any]) -> (service: String, content: String) {
        var info = (service: "", content: "")
//        guard let aps = userInfo["aps"] as? [String: Any] else { return info }
//        guard let userinfo = aps["alert_data"] as? [String: Any] else { return info }
//        let service = userinfo["service"] as? String ?? ""
//        let id = userinfo["id"] as? String ?? ""
//        info = (service: service, id: id)
//        guard let aps = userInfo["aps"] as? [String: Any] else { return info }
        guard let content = userInfo["alert_data"] as? String else {
            return info
        }
        let data = content.data(using: String.Encoding.utf8)
        guard let userinfo = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any] else {
            return info
        }
        let service = userinfo["service"] as? String ?? ""
        let id = userinfo["content"] as? String ?? ""
        info = (service: service, content: id)
        return info
    }
    func handleService(service: String, content: String) {
        switch service {
        case "violas_00":
            print("123")
        case "violas_01":
            print("123")
        case "violas_02":
            print("123")
        case "violas_03":
            print("123")
        case "violas_04":
            print("123")
        case "violas_05":
            print("123")
        case "violas_06":
            print("123")
        case "violas_07":
            print("123")
        default:
            print("无法处理")
        }
    }
}
extension AppDelegate: MessagingDelegate {
    // FCM tokens are always provided here. It is called generally during app start, but may be called
    // more than once, if the token is invalidated or updated. This is the right spot to upload this
    // token to your application server, or to subscribe to any topics.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let token = Messaging.messaging().fcmToken {
            print("FCM Token: \(token)")
            let dataDict:[String: String] = ["token": fcmToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        } else {
            print("FCM Token: nil")
        }
    }
}
