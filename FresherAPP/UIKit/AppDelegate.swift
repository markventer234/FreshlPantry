import Foundation
import UIKit


import SwiftUI
import OneSignal


@main

class AppDelegate: UIResponder, UIApplicationDelegate {
  
    
   static var orientationLock =
   UIInterfaceOrientationMask.all

   func application(_ application: UIApplication,
   supportedInterfaceOrientationsFor window:
   UIWindow?) -> UIInterfaceOrientationMask {
   return AppDelegate.orientationLock
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       OneSignal.initWithLaunchOptions(launchOptions)
       OneSignal.setAppId("2355491a-91a2-4af7-960b-dad528b817a6")
       OneSignal.promptForPushNotifications(userResponse: { accepted in
               })
       OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

       return true
   }

   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
       return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }

   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
 
       
   }

    

   
   

}

