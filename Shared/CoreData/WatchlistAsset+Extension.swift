//
//  AssetEntity+Extension.swift
//  RatesView iOS
//
//  Created by Esie on 2/5/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import UIKit
import RWExtensions
import CoreData

typealias CDWatchlistAssetAdapter = WatchlistAsset

extension CDWatchlistAssetAdapter {
    
    static let identifier = "WatchlistAsset"
    
    convenience init(internalFullCode: String) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.internalFullCode = internalFullCode
    }
    
}

extension CDWatchlistAssetAdapter {
    
    /// Example "BITSTAMP:BTCUSD"
    var fullCode: String {
        return source + ":" + baseCurrency + currency
    }
    
    /// Example "BTCUSD"
    var code: String {
        return baseCurrency + currency
    }
    
    /// Example "BITSTAMP"
    var source: String {
        let splitedCode = internalFullCode!.split(separator: ":", maxSplits: 1)
        return String(splitedCode[0])
    }
    
    /// Example "BTC"
    var currency: String {
        let splitedCode = unsafeRawCode.split(separator: "-", maxSplits: 1)
        return String(splitedCode[1])
    }
    
    var converterPrice: Double {
        if isCrypto {
            return Double(truncating: price ?? 0)
        } else {
            return currency == "USD" ? 1.0 : Double(truncating: price ?? 0)
        }
    }
    
    /// Example "BTC"
    var currencyToUSD: String {
          let splitedCode = unsafeRawCode.split(separator: "-", maxSplits: 1)
          return isCurrency ? String(splitedCode[1]) : String(splitedCode[0])
    }
    
    /// Example "USD"
    var baseCurrency: String {
        let splitedCode = unsafeRawCode.split(separator: "-", maxSplits: 1)
        return String(splitedCode[0])
    }
    
    /// Example .crypto
    var classType: FinanceAsset {
        let filtered = FinanceAsset.typeCheckSource.filter { $0.contains(source) }
        return FinanceAsset(rawValue: FinanceAsset.typeCheckSource.firstIndex(of: filtered[0])!)!
    }
    
    var pricePlaces: Int {
        switch classType {
        case .crypto:
            return 4
        case .currency:
            return 5
        case .other, .stock:
            return 2 
        }
    }
    
    var converterPricePlaces: Int {
        switch classType {
        case .crypto:
            return 4
        case .currency, .other, .stock:
            return 2
        }
    }
    
    var unsafeRawCode: String {
        let splitedCode = internalFullCode!.split(separator: ":", maxSplits: 1)
        return String(splitedCode[1])
    }
    
    /// Chart Image
    var chart: UIImage? {
        return chartImage != nil ? UIImage(data: chartImage!)! : nil
    }
    
    /// Icon Image
    var icon: UIImage? {
        return iconImage != nil ? UIImage(data: iconImage!)! : nil
    }
    
    var currencyCountryCode: String? {
        return isCurrency ? (currency[0] + currency[1]).lowercased() : nil
    }
    
    var isDetailedLoaded: Bool {
        return iconImage != nil && name != nil
    }
    
    var isStock: Bool {
        return classType == .stock
    }
    
    var isCurrency: Bool {
        return classType == .currency
    }
    
    var isCrypto: Bool {
        return classType == .crypto
    }
    
    var isOther: Bool {
        return classType == .other
    }
    
    var globalWatchlistIndex: Int {
        return Int(positionInWatchlist)
//        do {
//            let context = AppDelegate.persistentContainer.viewContext
//            let allSections = try context.fetch(CDWatchlistSectionAdapter.fetchRequest())
//            var prevAssets = 0
//
//            allSections.forEach {
//                if ($0 as! CDWatchlistSectionAdapter).position < section!.position {
//                    prevAssets += ($0 as! CDWatchlistSectionAdapter).assets!.count
//                }
//            }
            
            //return Int(positionInWatchlist) //+ prevAssets
//        } catch {
//            return 0
//        }
    }
    
}
