//
//  QuickSearchInteractor.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import CoreData
import RWExtensions

final class QuickSearchInteractor: RWInteractor {
    
    unowned var presenter: QuickSearchPresenter!
    
    var allAssetList = [String]()
    
    //MARK: Initial Data Check
    
    override func initialDataSourceCheck() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            #if TARGET_RW || TARGET_CER || TARGET_CERPRO
            
            #endif
            
            #if TARGET_SC || TARGET_RW || TARGET_CER || TARGET_CERPRO
            // Add all currencies to the quick search menu.
            let currencies = FinanceAsset.currenciesDataModel().map { $0.items }
            currencies.forEach { (items) in
                self.allAssetList.append(contentsOf: items)
            }
            #endif
            
            #if TARGET_CW || TARGET_SC
            // Add all crypto to the quick search menu.
            let crypto = FinanceAsset.cryptoDataModel().map { $0.items }
            crypto.forEach { (items) in
                self.allAssetList.append(contentsOf: items)
            }
            #endif
            
            // Sort all assets by name.
            self.allAssetList.sort { assetName(fromInternalCode: $0) < assetName(fromInternalCode: $1) }
            
            // Update view controller's ui on the main thread.
            DispatchQueue.main.async {
                self.presenter.viewController.updateDataSource(animated: false)
            }
        }
    }
}
