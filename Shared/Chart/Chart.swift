//
//  Chart.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

enum Chart {
    
    static func construct(option: LauchOption? = nil, context: Any? = nil) -> ChartViewController {
        let viewController = ChartViewController()
        let presenter = ChartPresenter()
        let interactor = ChartInteractor()
        let router = ChartRouter()
        viewController.presenter = presenter
        viewController.basePresenter = presenter
        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.baseInteractor = interactor
        presenter.baseViewController = viewController
        presenter.router = router
        interactor.presenter = presenter
        router.presenter = presenter
        router.viewController = viewController
        presenter.launchContext = context
        presenter.launchOption = option
        return viewController
    }
    
    enum LauchOption {
        case fromTabBar
        case fromWatchlist
    }
    
}
