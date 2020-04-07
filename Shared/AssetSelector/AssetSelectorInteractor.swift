//
//  ModuleIntercator.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import CoreData
import RWExtensions

final class AssetSelectorInteractor: RWInteractor {
    
    unowned var presenter: AssetSelectorPresenter!
    
    override func initialDataSourceCheck() {
        
    }

    override func dataSourceIsEmpty(context: NSManagedObjectContext, entity: String) {
        
    }
    
}


