//
//  SceneDelegate.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import CoreModules

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var window: UIWindow!
    static var tabBar: UITabBarController!
    static var watchlist: Watchlist.ViewController!
    static var chart: Chart.ViewController!
    static var converter: Converter.ViewController!
    static var porfolio: Watchlist.ViewController!
    static var more: RPReusableTableViewController!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AnalyticsEvents.applicationType = "RatesView"
        
        if let windowScene = scene as? UIWindowScene {
            SceneDelegate.window = UIWindow(windowScene: windowScene)
         
            SceneDelegate.watchlist = Watchlist.construct()
            let watchlist = UINavigationController(rootViewController: SceneDelegate.watchlist)
            watchlist.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(named: "Watchlist"), tag: 0)
            
            SceneDelegate.chart = Chart.construct(options: [.fromTabBar], context: nil)
            let chart = UINavigationController(rootViewController: SceneDelegate.chart)
            chart.tabBarItem = UITabBarItem(title: "Chart", image: UIImage(named: "Chart"), tag: 1)
            
            SceneDelegate.converter = Converter.construct()
            let converter = UINavigationController(rootViewController: SceneDelegate.converter)
            converter.tabBarItem = UITabBarItem(title: "Converter", image: UIImage(named: "Converter"), tag: 2)
            
            let portfolio = UINavigationController(rootViewController: Watchlist.construct())
            portfolio.tabBarItem = UITabBarItem(title: "Portfolio", image: UIImage(named: "Portfolio"), tag: 3)
            
            let moreVC = MoreTab.parent()
            let more = UINavigationController(rootViewController: moreVC)
            more.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "More"), tag: 4)
            
            let tabBar = UITabBarController()
            tabBar.viewControllers = [watchlist, chart, converter, portfolio, more]
           
            SceneDelegate.tabBar = tabBar
            SceneDelegate.window.rootViewController = tabBar
            SceneDelegate.window.makeKeyAndVisible()
        }
    }

    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    func sceneDidDisconnect(_ scene: UIScene) {
       
    }

    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    // Save changes in the application's managed object context when the application transitions to the background.
    func sceneDidEnterBackground(_ scene: UIScene) {
        AppDelegate.saveContext()
    }
    
}

