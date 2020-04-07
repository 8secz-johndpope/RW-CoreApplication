//
//  WatchlistRouter.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import RWExtensions
import RWUserInterface
import UIKit

final class WatchlistRouter {
    
    unowned var presenter: WatchlistPresenter!
    unowned var viewController: WatchlistViewController!
    
    //MARK: Types
    
    enum Routes: Int {
        case toChart = 1
        case toProfile = 2
        case toFinancials = 3
        case addStock = 4
        case addCurrency = 5
        case addCrypto = 6
        case toSettings = 7
        case toQuickSearch = 8
        case toSeeAll = 21
    }
    
    //MARK: Routes
    
    func routeTo(_ to: Routes, context: Any? = nil) {
        switch to {
            
        #if CRYPTOVIEW
        case .addCurrency:
            guard let startFrame = context as? CGRect else { return }
            let selectorVC = AssetSelector.construct(option: .currencies)
            let contextWindow = RWContextWindowViewController(parentViewController: viewController)
            contextWindow.customPresentationFrameStart = startFrame
            contextWindow.customPresentationFrameEnd = viewController.standartPresentationFrame
            contextWindow.present(viewController: selectorVC, presentationType: .customFrame)
        #endif
            
        case .addCrypto:
            guard let startFrame = context as? CGRect else { return }
            let selectorVC = AssetSelector.construct(option: .crypto)
            let contextWindow = RWContextWindowViewController(parentViewController: viewController)
            contextWindow.customPresentationFrameStart = startFrame
            contextWindow.customPresentationFrameEnd = viewController.standartPresentationFrame
            contextWindow.present(viewController: selectorVC, presentationType: .customFrame)
            
        case .toChart:
            let chart = Chart.construct(option: .fromWatchlist, context: context)
            viewController.present(UINavigationController(rootViewController: chart), animated: true)
            
        case .toQuickSearch:
            AnalyticsEvent.register(source: .quicksearch, key: RWAnalyticsEventOpened)
            let quickVC = QuickSearch.construct()
            let contextWindow = RWContextWindowViewController(parentViewController: viewController)
            contextWindow.present(viewController: quickVC, presentationType: .animatedTop)
            
        default:
            break
        }
    }
}
