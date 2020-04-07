//
//  ModuleRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation

extension SeeAll {
    
    final class Router: BaseRouter {
        
        unowned var presenter: Presenter!
        unowned var viewController: ViewController!
        
        //MARK: - Types
        
        enum Routes: Int {
            case toChart = 1
            case toProfile = 2
            case toFinancials = 3
            case toAdd = 4
            case toSeeAll = 5
        }
        
        //MARK: - Routes
        
        func routeTo(_ to: Routes, context: Any? = nil) {
                   
        }
        
    }
    
}
