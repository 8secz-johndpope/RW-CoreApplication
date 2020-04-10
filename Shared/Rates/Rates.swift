//
//  Rates.swift
//  RatesView
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import RWExtensions

enum Rates {
    
    static func construct(option: LauchOption? = nil, context: Any? = nil) -> RatesViewController {
        let viewController = RatesViewController()
        let presenter = RatesPresenter()
        let interactor = RatesInteractor()
        let router = RatesRouter()
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
        case none
    }
    
}
