//
//  ModuleRouter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions

final class AssetSelectorRouter {
    
    unowned var presenter: AssetSelectorPresenter!
    unowned var viewController: AssetSelectorViewController!
    
    //MARK: Types
    
    enum Routes: Int {
        case toParent = 0
    }
    
    //MARK: Routes
    
    func routeTo(_ to: Routes, context: Any? = nil) {
        switch to {
            
        case .toParent:
            viewController.dismiss(animated: true)
        }
    }
}
