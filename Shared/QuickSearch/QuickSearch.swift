//
//  Module.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

enum QuickSearch {
    
    static func construct(option: LauchOption? = nil, context: Any? = nil) -> QuickSearchViewController {
        let viewController = QuickSearchViewController()
        let presenter = QuickSearchPresenter()
        let interactor = QuickSearchInteractor()
        let router = QuickSearchRouter()
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
