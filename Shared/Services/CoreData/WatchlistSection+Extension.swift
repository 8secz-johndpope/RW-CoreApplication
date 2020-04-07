//
//  SectionEntity+Extension.swift
//  RatesView iOS
//
//  Created by Esie on 2/6/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import RWExtensions
import CoreData

typealias CDWatchlistSectionAdapter = WatchlistSection

extension CDWatchlistSectionAdapter {
    
    static let identifier = "WatchlistSection"
    
    convenience init(title: String) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.title = title
    }
    
    convenience init(title: String, position: Int16) {
        self.init(context: AppDelegate.persistentContainer.viewContext)
        self.title = title
        self.position = position
    }
    
    func addAsset(internalFullCode: String, rowInConverter: Int16 = 0, overrrideRowInConverter: Int16? = nil) {
        let asset = WatchlistAsset(internalFullCode: internalFullCode)
        let index = Int16(assets!.count)
        asset.positionInWatchlist = index
        asset.sectionInConverter = 0
        asset.rowInConverter = overrrideRowInConverter ?? index + rowInConverter
        
        #if SECONVERTER
        asset.iconImage = assetIcon(fromInternalCode: internalFullCode)?.pngData()
        asset.name = assetName(fromInternalCode: internalFullCode)
        #else
        if !asset.isStock {
            asset.iconImage = assetIcon(fromInternalCode: internalFullCode)?.pngData()
            asset.name = assetName(fromInternalCode: internalFullCode)
        }
        #endif
        
        self.addToAssets(asset)
    }
}
