//
//  WebSession.swift
//  RatesView
//
//  Created by Esie on 2/6/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import CoreData
import RWSession
import RWExtensions
import UIKit

enum WebSession {
    
    /// Convert watchlist assets to brigde objects and start price update session.
    static func beginUpdates() {
        let context = AppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CDWatchlistAssetAdapter.identifier)
        
        do {
            let corePersistentStore = try context.fetch(fetchRequest)
            var assets = corePersistentStore.map { $0 as! CDWatchlistAssetAdapter }
            assets = assets.filter { $0.unsafeRawCode != "USD-USD" }
            var sessionAssets = [AssetBridgeObject]()
            
            DispatchQueue.global(qos: .userInitiated).async {
                assets.forEach { (assetEntity) in
                    
                    if !assetEntity.isStock {
                        let code = assetEntity.internalFullCode!
                        let icon = assetIcon(fromInternalCode: code)!
                        assetEntity.iconImage = icon.pngData()
                        assetEntity.name = assetName(fromInternalCode: assetEntity.internalFullCode!)
                    }
                    
                    let isDetailed = assetEntity.isStock && assetEntity.name != nil &&
                        assetEntity.hasNoIcon == false && assetEntity.icon == nil
                    
                    let asset = AssetBridgeObject(fullCode: assetEntity.fullCode, isDetailed: isDetailed)
                    
                    sessionAssets.append(asset)
                    
                }
                
                DispatchQueue.main.async {
                     RWSession.sharedInstance().openSession(with: sessionAssets)
                     RWSession.sharedInstance().startSession()
                }
               
            }
            
        } catch let error as NSError {
            print("PPS: Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
