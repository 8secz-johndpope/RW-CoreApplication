//
//  SceneDelegate.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWUserInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var window: UIWindow!
    static var tabBar: UITabBarController!
    static var rates: RatesViewController!
    static var chart: ChartViewController!
    static var converter: ConverterViewController!
    static var settings: RWReusableTableViewController!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            SceneDelegate.window = UIWindow(windowScene: windowScene)
         
            // Currencies tab
            SceneDelegate.rates = Rates.construct()
            let watchlist = SceneDelegate.rates!
            watchlist.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(named: "Watchlist"), tag: 0)

            // Chart tab
            SceneDelegate.chart = Chart.construct()
            let chart = SceneDelegate.chart!
            chart.tabBarItem = UITabBarItem(title: "Chart", image: UIImage(named: "Chart"), tag: 1)
            
            // Converter tab
            SceneDelegate.converter = Converter.construct()
            let converter = SceneDelegate.converter!
            converter.tabBarItem = UITabBarItem(title: "Converter", image: UIImage(named: "Converter"), tag: 2)
            
            // Settings tab
            SceneDelegate.settings = Settings.settingsParentPage
            let settings = SceneDelegate.settings!
            settings.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "More"), tag: 3)
            
            // Configure tab bar and main window
            let tabBar = UITabBarController()
            tabBar.viewControllers = [watchlist, chart, converter, settings]
            SceneDelegate.tabBar = tabBar
            SceneDelegate.window.rootViewController = tabBar
            SceneDelegate.window.makeKeyAndVisible()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AppDelegate.saveContext()
    }
    
}

