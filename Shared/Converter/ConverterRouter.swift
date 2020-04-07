//
//  ModuleRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import RWExtensions

final class ConverterRouter {
        
        unowned var presenter: ConverterPresenter!
        unowned var viewController: ConverterViewController!
        
        //MARK: Types
        
        enum Routes: Int {
            case toChart = 1
        }
        
        //MARK: Routes
        
        func routeTo(_ to: Routes, context: Any? = nil) {
            switch to {
                
            
                
            default:
                break
            }
        }
    }
