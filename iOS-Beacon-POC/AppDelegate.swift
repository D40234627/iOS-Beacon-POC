//
//  AppDelegate.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 9/28/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var questionNumber: String = ""
    var questionText: String = ""

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
//        if #available(iOS 10.0, *) {
//            let authOptions : UNAuthorizationOptions = [.Alert, .Badge, .Sound]
//            UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions(
//                authOptions,
//                completionHandler: {_,_ in })
//            
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.currentNotificationCenter().delegate = self
//            // For iOS 10 data message (sent via FCM)
//            FIRMessaging.messaging().remoteMessageDelegate = self
//            
//        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
//        }
        
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tokenRefreshNotification:", name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        print("%@", userInfo)
        questionNumber = userInfo["questionNumber"] as! String
        questionText = userInfo["questionText"] as! String
        NSNotificationCenter.defaultCenter().postNotificationName("feedbackNotification", object: nil)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
        print("Device Token:", tokenString)
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        print("i am the function")
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        } else {
            print("refreshed token is nil")
        }
        
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect to fcm. \(error)")
            } else {
                print("connected to fcm.")
            }
        }
    }

}

//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//    // Receive displayed notifications for iOS 10 devices.
//    func userNotificationCenter(center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
//            let userInfo = notification.request.content.userInfo
//            // Print message ID.
//            print("Message ID: \(userInfo["gcm.message_id"]!)")
//            
//            // Print full message.
//            print("%@", userInfo)

//            questionNumber = userInfo["questionNumber"] as! String
//            questionText = userInfo["questionText"] as! String
//            NSNotificationCenter.defaultCenter().postNotificationName("feedbackNotification", object: nil)
//    }
//}
//
//extension AppDelegate : FIRMessagingDelegate {
//    // Receive data message on iOS 10 devices.
//    func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
//        print("%@", remoteMessage.appData)
//        questionNumber = remoteMessage.appData["questionNumber"] as! String
//        questionText = remoteMessage.appData["questionText"] as! String
//        NSNotificationCenter.defaultCenter().postNotificationName("feedbackNotification", object: nil)
//    }
//}


