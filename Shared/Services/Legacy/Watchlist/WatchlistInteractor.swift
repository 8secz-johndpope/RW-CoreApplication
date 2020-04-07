//
//  WatchlistIntercator.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Watchlist {
    
    final class Interactor: BaseInteractor {
        
        unowned var presenter: Presenter!
        
        private var isLoaded = false
        
        //MARK: Initial Data Check
        
        override func initialDataSourceCheck() {
            let context = AppDelegate.persistentContainer.viewContext
            loadFromContext(context, entity: CDWatchlistSectionAdapter.identifier)
            startUpdates()
        }
        
        //MARK: Data Source Is Empty

        override func dataSourceIsEmpty(context: NSManagedObjectContext, entity: String) {

            #if RATESVIEW_PRO || RATESVIEW_BASE || CRYPTOVIEW
            let prtfSection = CDWatchlistSectionAdapter(context: context)
            prtfSection.isPortfolioSection = true
            prtfSection.position = 0
            prtfSection.title = "Portfolio"
            dataSource.append(prtfSection)
            
            let pItem = PortfolioItem(context: context)
            pItem.isGeneral = true
            pItem.position = 0
            pItem.title = "Overview"
            prtfSection.addToPortfolioItems(pItem)
            
            let pItem2 = PortfolioItem(context: context)
            pItem2.isGeneral = false
            pItem2.position = 1
            pItem2.title = "Test"
            prtfSection.addToPortfolioItems(pItem2)
            #endif
            
            #if RATESVIEW_PRO || RATESVIEW_BASE
            addsection(title: "Stocks", position: 1,
                       entities: ["NASDAQ:AAPL-NaN", "NASDAQ:MSFT-NaN", "NASDAQ:INTC-NaN", "NASDAQ:TSLA-NaN", "NASDAQ:AMD-NaN"])
            #endif
            
            #if !CRYPTOVIEW
            addsection(title: "Currencies", position: 2,
                       entities: ["FX_IDC:EUR-USD", "FX_IDC:USD-GBP", "FX_IDC:USD-JPY", "FX_IDC:USD-CAD", "FX_IDC:USD-RUB", "FX_IDC:USD-AUD"])
            #endif
            
            #if !ARCONVERTER
            addsection(title: "Crypto", position: 3,
                       entities: ["COINBASE:BTC-USD", "COINBASE:ETH-USD", "COINBASE:LTC-USD", "COINBASE:XRP-USD"], prevSectionsCount: 6)
            #endif
            
            let usd = CDWatchlistAssetAdapter(context: context)
            usd.price = 1.0
            usd.iconImage = UIImage(named: "us")?.pngData()
            usd.internalFullCode = "FX_IDC:USD-USD"
            usd.rowInConverter = 0
            usd.name = "US Dollar"
            usd.sectionInConverter = 0
            
            startUpdates()
        }
        
        private func addsection(title: String, position: Int16, entities: [String], converterMask: [Bool] = [], prevSectionsCount: Int16 = 0) {
            let section = CDWatchlistSectionAdapter(title: title, position: position)
            entities.forEach { section.addAsset(internalFullCode: $0, rowInConverter: prevSectionsCount) }
            dataSource.append(section)
        }
        
        private func startUpdates() {
            if !isLoaded {
                WebSession.beginUpdates()
                isLoaded = true
            }
        }
        
    }
}


