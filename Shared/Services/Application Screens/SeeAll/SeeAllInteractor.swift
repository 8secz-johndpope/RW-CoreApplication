//
//  ModuleIntercator.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import CoreData

extension SeeAll {
    
    final class Interactor: BaseInteractor {
        
        unowned var presenter: Presenter!
        
        //MARK: - Interactor Properties
        
        //MARK: - Initial Data Check
        
        /// Called automatically after presenter's didLoad()
        override func initialDataSourceCheck() {
            
        }
        
        /// Called automatically is loaded dataSource is empty
        /// Should be used to populate CoreData model with initial data
        override func dataSourceIsEmpty(context: NSManagedObjectContext, entity: String) {
            
        }
        
    }
}


