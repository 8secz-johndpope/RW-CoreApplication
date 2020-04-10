//
//  QuickSearchRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface

final class QuickSearchRouter {
    
    unowned var presenter: QuickSearchPresenter!
    unowned var viewController: QuickSearchViewController!
    
    //MARK: Types
    
    enum Routes: Int {
        case toChart = 1
    }
    
    //MARK: Routes
    
    func routeTo(_ to: Routes, context: Any? = nil) {
        switch to {
            
        case .toChart:
            resignCurrentContextController()
            let chart = Chart.construct(option: .fromWatchlist, context: context)
            viewController.present(UINavigationController(rootViewController: chart), animated: true)

        }
    }
}
