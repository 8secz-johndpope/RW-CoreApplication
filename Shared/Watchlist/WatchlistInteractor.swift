//
//  WatchlistInteractor.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import CoreData
import RWExtensions
import UIKit

final class WatchlistInteractor: RWInteractor {
    
    unowned var presenter: WatchlistPresenter!
    
    private var isLoaded = false
    
    //MARK: Initial Data Check
    
    override func initialDataSourceCheck() {
        let context = AppDelegate.persistentContainer.viewContext
        loadFromContext(context, entity: CDWatchlistSectionAdapter.identifier)
        startUpdates()
    }
    
    //MARK: Data Source Is Empty
    
    /// Create initial watchlist assets.
    override func dataSourceIsEmpty(context: NSManagedObjectContext, entity: String) {

        // Assets data source full codes.
        let currencies = ["FX_IDC:EUR-USD", "FX_IDC:USD-EUR", "FX_IDC:USD-RUB"]
        let crypto = ["COINBASE:BTC-USD", "COINBASE:ETH-USD", "COINBASE:XRP-USD"]
        
        // Enable currencies section on all apps.
        addsection(title: "Fiat", position: 0, entities: currencies)
        
        // Enable crypto section only for SE App.
        let currenciesCount = Int16(currencies.count)
        addsection(title: "Crypto", position: 1, entities: crypto, prevSectionCount: currenciesCount)
        
        startUpdates()
    }
    
    /// Add single section to the watchlist.
    private func addsection(title: String, position: Int16, entities: [String], prevSectionCount: Int16 = 0) {
        let section = CDWatchlistSectionAdapter(title: title, position: position)
        entities.forEach { section.addAsset(internalFullCode: $0, rowInConverter: prevSectionCount) }
        dataSource.append(section)
    }
    
    /// Convert watchlist assets to brigde objects and start price update session.
    private func startUpdates() {
        if !isLoaded {
            WebSession.beginUpdates()
            isLoaded = true
        }
    }
}
