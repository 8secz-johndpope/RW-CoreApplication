//
//  SceneDelegate.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var window: UIWindow!
    static var tabBar: UITabBarController!
    static var rates: RatesViewController!
    static var converter: ConverterViewController!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            SceneDelegate.window = UIWindow(windowScene: windowScene)
         
            // Currencies tab
            SceneDelegate.rates = Rates.construct()
            let watchlist = SceneDelegate.rates!
            watchlist.tabBarItem = UITabBarItem(title: NSLocalizedString("Watchlist", comment: ""), image: UIImage(named: "Watchlist"), tag: 0)

            // Converter tab
            SceneDelegate.converter = Converter.construct()
            let converter = SceneDelegate.converter!
            converter.tabBarItem = UITabBarItem(title: NSLocalizedString("Converter", comment: ""), image: UIImage(named: "Converter"), tag: 2)
            
            // Configure tab bar and main window
            let tabBar = UITabBarController()
            tabBar.viewControllers = [watchlist, converter]
            SceneDelegate.tabBar = tabBar
            SceneDelegate.window.rootViewController = tabBar
            SceneDelegate.window.makeKeyAndVisible()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AppDelegate.saveContext()
    }
    
}

