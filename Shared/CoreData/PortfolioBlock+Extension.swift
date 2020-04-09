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

extension CDPortfolioBlockAdapter {
    
    static let identifier = "PortfolioBlock"
    
    convenience init(amount: Decimal, currency: Code, category: String, subcategory: String) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        
    }
    
}

extension CDPortfolioBlockAdapter {
    
    var category: String {
        return typeCategory ?? "Default"
    }
    
    var subCategory: String {
        return typeSubcategory ?? "Default"
    }

}


typealias CDPortfolioSectionAdapter = PortfolioSection

extension CDPortfolioSectionAdapter {
    
    static let identifier = "PortfolioSection"
    
    convenience init(title: String = "Account Name", position: Int16) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.title = title
        self.position = position
    }
    
}

extension CDPortfolioSectionAdapter {
    
    var operations: [PortfolioBlock] {
        let allBlocks = self.blocks?.allObjects as? [PortfolioBlock] ?? []
        return allBlocks.sorted { $0.timestamp! < $1.timestamp! }
    }

}
