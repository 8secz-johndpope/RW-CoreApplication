//
//  ModuleRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

final class ChartRouter {
    
    unowned var presenter: ChartPresenter!
    unowned var viewController: ChartViewController!
    
    //MARK: Types
    
    enum Routes: Int {
        case toChart = 1
        case toProfile = 2
        case toFinancials = 3
        case open = 4
        case toSaved = 5
        case toOptions = 6
        case toIndicators = 7
    }
    
    //MARK: Routes
    
    func routeTo(_ to: Routes, context: Any? = nil) {
        switch to {
            
        case .toIndicators:
            let indicatorsVC = IndicatorsViewController()
            indicatorsVC.presenter = presenter
            viewController.navigationController?.pushViewController(indicatorsVC, animated: true)
            
        case .open:
            break
            //                let tabBar = SceneDelegate.tabBar!
            //                let chartNav = tabBar.viewControllers![1] as! UINavigationController
            //                let chart = chartNav.viewControllers[0] as! Chart.ViewController
            //                chart.presenter.launchContext = context
            //                chart.dataSourceDidChanged(animated: false)
            //                SceneDelegate.tabBar.selectedIndex = 1
            
        case .toSaved:
            break
//            let savedVC = RPReusableTableViewController()
//            savedVC.setPageType(.fullview)
//            savedVC.setPageTitle("Saved Charts")
//            savedVC.addButtons([RPButton(label: "Chart")])
//            viewController.navigationController?.pushViewController(savedVC, animated: true)
            
        case .toOptions:
            break
//            let options = RPReusableTableViewController()
//            options.setPageType(.fullview)
//            options.setPageTitle("")
//
//            options.addSection(RPSection([
//                RPButton(button: "Save Chart") {
//
//                }
//            ]))
//
//            let incVC = ChartIndicatorsViewController()
//            incVC.presenter = presenter
//
//            options.addSection(RPSection([
//                RPButton(customRouter: "Indicators", to: incVC)
//            ]))
//
//            viewController.navigationController?.pushViewController(options, animated: true)
            
        default:
            break
        }
    }
}
