//
//  Watchlist.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit

final class Watchlist {
    
    static func construct(options: [Options]? = nil, context: Any? = nil) -> ViewController {
        let viewController = ViewController()
        let presenter = Presenter()
        let interactor = Interactor()
        let router = Router()
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
        presenter.launchOptions = options
        return viewController
    }
    
    enum Options {

    }
    
}
