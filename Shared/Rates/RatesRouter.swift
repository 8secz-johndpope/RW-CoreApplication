//
//  RatesRouter.swift
//  RatesView
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import RWExtensions
import RWUserInterface
import UIKit

final class RatesRouter {
    
    unowned var presenter: RatesPresenter!
    unowned var viewController: RatesViewController!
    
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
        case showContextOption = 9
        case toIntro = 10
        case toSeeAll = 21
    }
    
    //MARK: Routes
    
    func routeTo(_ to: Routes, context: Any? = nil) {
        switch to {
            
        case .toIntro:
            let introVC = RWIntroViewController(buttons: ["Next", "OK"])
            introVC.modalPresentationStyle = .custom
            viewController.present(introVC, animated: false)
            
        case .addCurrency:
            guard let startFrame = context as? CGRect else { return }
            let selectorVC = AssetSelector.construct(option: .currencies)
            let contextWindow = RWContextWindowViewController(parentViewController: viewController)
            contextWindow.customPresentationFrameStart = startFrame
            contextWindow.customPresentationFrameEnd = viewController.standartPresentationFrame
            contextWindow.present(viewController: selectorVC, presentationType: .customFrame)
            
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
            
        case .showContextOption:
            guard let completion = context as? (Int) -> Void else { return }
            
            #if TARGET_CW
            completion(1)
            #endif
            
            #if TARGET_SC
            let cells = ["Currency-Source is forex market",
                         "Crypto-Supported sources: Bitstamp, Coinbase, Binance, Poloniex, Kraken"]
            
            let icons = [UIImage(named: "currencies")!, UIImage(named: "crypto")!]
            
            let callbacks = [{
                    resignCurrentContextController()
                    completion(0)
                }, {
                    resignCurrentContextController()
                    completion(1)
                }]
            
            let optionVC = BigContextViewController(cells: cells, icons: icons, callbacks: callbacks)
            let sourceFrame = viewController.floatingButton.button.frame
            let size = CGSize(width: viewController.width*0.6, height: viewController.width*0.5)
            let origin = sourceFrame.corner - Vector2D(x: size.width, y: size.height)
            let contextWindow = RWContextWindowViewController(parentViewController: viewController)
            contextWindow.customPresentationFrameStart = sourceFrame
            contextWindow.customPresentationFrameEnd = CGRect(origin: origin, size: size)
            contextWindow.present(viewController: optionVC, presentationType: .customFrame)
            #endif
            
        case .toSettings:
            break
//            let vc = settingsParentPage
//            vc.backgroundColor = .background
//            vc.backgroundSecondaryColor = .itemBackground
//            vc.enableCloseButton = true
//            viewController.present(UINavigationController(rootViewController: vc), animated: true)
            
        default:
            break
        }
    }
}
