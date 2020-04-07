//
//  ModuleRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit

extension Watchlist {
    
    final class Router {
        
        unowned var presenter: Presenter!
        unowned var viewController: ViewController!
        
        //MARK: Types
        
        enum Routes: Int {
            case toChart = 1
            case toProfile = 2
            case toFinancials = 3
            case addStock = 4
            case addCurrency = 5
            case addCrypto = 6
            case toSeeAll = 21
        }
        
        //MARK: Routes
        
        func routeTo(_ to: Routes, context: Any? = nil) {
            switch to {
                
            case .addStock:
                let addAssetViewController = AddAsset.construct(option: .stocks)
                viewController.showPresentedMenu(addAssetViewController)
                
            case .addCurrency:
                let addAssetViewController = AddAsset.construct(option: .currencies)
                viewController.showPresentedMenu(addAssetViewController)
                
            case .addCrypto:
                let addAssetViewController = AddAsset.construct(option: .crypto)
                viewController.showPresentedMenu(addAssetViewController)
                
            case .toChart:
                let chart = Chart.construct(options: [.fromWatchlist], context: context)
                viewController.present(UINavigationController(rootViewController: chart), animated: true)
                
                
                
                
                //            case .toSeeAll:
//                let seeAll = SeeAll.construct(context: context)
//                viewController.open(seeAll, pushed: true)
                
            default:
                break
            }
        }
    }
}
