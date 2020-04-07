//
//  AppDelegate.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import CoreData
import RWSession
import RWExtensions
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let devEmail = "d.esie@icloud.com"
    static let appID = "1441623007"
    static let internalVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let appName = "CryptoView"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.global(qos: .userInitiated).async {
            AppDelegate.setInitialSettings()
            
            let session = RWSession.sharedInstance()
            let hardwareProfile = HardwareScalability.performanceProfile
            session.maxSimultaneousThreads = hardwareProfile.chartLoadersMaxThreads
            session.initialFireInterval = hardwareProfile.initialUpdateInterval
            session.realtimeFireIntervalPercentage = 10//hardwareProfile.realtimeUpdateInterval
            session.loadOnlyVisibleAssets = true
            session.forceDisableRealtime = true
            session.forceDisableCharts = true
            
            FirebaseApp.configure()
            AnalyticsEvent.applicationType = AppDelegate.appName
            AnalyticsEvent.register(key: RWAnalyticsEventOpened)
        }
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
