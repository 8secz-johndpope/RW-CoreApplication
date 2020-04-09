//
//  RatesInteractor.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import CoreData
import RWExtensions
import UIKit

final class RatesInteractor: RWInteractor {
    
    unowned var presenter: RatesPresenter!
    private var isLoaded = false
    
    #if ENABLE_PORTFOLIO
    var portfolioSections = [CDPortfolioSectionAdapter]()
    #endif
    
    //MARK: Initial Data Check
    
    override func initialDataSourceCheck() {
        let context = AppDelegate.persistentContainer.viewContext
        loadFromContext(context, entity: CDWatchlistSectionAdapter.identifier)
        
        #if ENABLE_PORTFOLIO
        portfolioSections = fetchEntities(in: context, entity: CDPortfolioSectionAdapter.identifier)
        #endif
        
        startUpdates()
    }
    
    //MARK: Data Source Is Empty
    
    /// Create initial watchlist assets.
    override func dataSourceIsEmpty(context: NSManagedObjectContext, entity: String) {
        setBasicModel()
        setCryptoModel()
        startUpdates()
    }
    
    //MARK: Smart Converter
    
    private func setBasicModel() {
        #if TARGET_SC
        let currencyCode = Locale.current.currencyCode ?? "USD"
        let localCurrency = currencyCode == "USD" ? "FX_IDC:EUR-USD" : "FX_IDC:USD-\(currencyCode)"
        let initialCurrencies = ["FX_IDC:EUR-USD", "FX_IDC:USD-EUR", "FX_IDC:USD-GBP", "FX_IDC:USD-JPY", "FX_IDC:USD-CAD", "FX_IDC:USD-RUB"]
        
        // Assets data source full codes.
        let currencies = initialCurrencies.contains(localCurrency) ? initialCurrencies : [localCurrency] + initialCurrencies
        let crypto = ["COINBASE:BTC-USD", "COINBASE:ETH-USD", "COINBASE:XRP-USD"]
         
        // Currencies section.
        addsection(title: "Currencies", position: 0, entities: currencies)
        
        // Crypto section.
        let currenciesCount = Int16(currencies.count)
        addsection(title: "Crypto", position: 1, entities: crypto, prevSectionCount: currenciesCount)
        #endif
    }
    
    //MARK: CryptoView
    
    private func setCryptoModel() {
        #if TARGET_CW
        let section = CDPortfolioSectionAdapter(title: "Overview", position: 0)
        
        // Assets data source full codes.
        let currencies = ["FX_IDC:EUR-USD", "FX_IDC:USD-EUR"]
        let crypto = ["COINBASE:BTC-USD", "COINBASE:ETH-USD", "COINBASE:XRP-USD", "COINBASE:LTC-USD", "COINBASE:BCH-USD", "COINBASE:DASH-USD", "COINBASE:ETC-USD"]
        
        // Currencies section.
        addsection(title: "Currencies", position: 0, entities: currencies)
        
        // Crypto section.
        addsection(title: "Crypto", position: 1, entities: crypto, prevSectionCount: 2)
        #endif
    }
    
}

extension RatesInteractor {
    
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
