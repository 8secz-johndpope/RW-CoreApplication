//
//  Converter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import RWExtensions

enum Converter {
    
    static func construct(option: LauchOption? = nil, context: Any? = nil) -> ConverterViewController {
        let viewController = ConverterViewController()
        let presenter = ConverterPresenter()
        let interactor = ConverterInteractor()
        let router = ConverterRouter()
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
        case inital
    }
    
}
