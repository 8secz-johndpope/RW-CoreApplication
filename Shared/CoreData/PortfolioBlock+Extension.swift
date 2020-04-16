//
//  PortfolioBlock+Extension.swift
//  CryptoView
//
//  Created by Esie on 4/9/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import RWExtensions
import CoreData

typealias CDPortfolioBlockAdapter = PortfolioBlock
typealias CDPortfolioBlocks = [PortfolioBlock]

extension CDPortfolioBlockAdapter {
    
    static let identifier = "PortfolioBlock"
    
    convenience init(amount: NSDecimalNumber, fee: NSDecimalNumber, asset: String, price: NSDecimalNumber, tag: String) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.amount = amount
        self.fee = fee
        self.asset = asset
        self.tag = tag
        self.price = price
        self.timestamp = Date()
    }
    
}

extension CDPortfolioBlockAdapter {
    
    var category: String {
        return tag ?? "Undefined"
    }
    
    var date: Date {
        return timestamp ?? Date()
    }
    
}


typealias CDPortfolioSectionAdapter = PortfolioSection

extension CDPortfolioSectionAdapter {
    
    static let identifier = "PortfolioSection"
    
    convenience init(title: String, position: Int16) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.title = title
        self.position = position
    }
    
}

extension CDPortfolioSectionAdapter {
    
    var operations: CDPortfolioBlocks {
        let allBlocks = self.blocks?.allObjects as? CDPortfolioBlocks ?? []
        return allBlocks.sorted { $0.date < $1.date }
    }

}
