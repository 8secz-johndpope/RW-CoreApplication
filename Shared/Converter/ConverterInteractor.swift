//
//  ConverterInteractor.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import CoreData
import RWExtensions

final class ConverterInteractor: RWInteractor {
    
    unowned var presenter: ConverterPresenter!
    var activeList = [CDWatchlistAssetAdapter]()
    var hiddenList = [CDWatchlistAssetAdapter]()
    
    //MARK: Initial Data Check
    
    override func initialDataSourceCheck() {
        reloadData()
    }
    
    /// Reloads converter currencies.
    func reloadData() {
        activeList.removeAll()
        hiddenList.removeAll()
        
        let context = AppDelegate.persistentContainer.viewContext
        loadFromContext(context, entity: CDWatchlistAssetAdapter.identifier)
        let list = dataSource.map { $0 as! CDWatchlistAssetAdapter }
        
        #if ENABLE_STOCKS
        list = persistentList.filter { !$0.isStock }
        #endif
        
        list.forEach { $0.sectionInConverter == 0 ? activeList.append($0) : hiddenList.append($0) }
    }
}
