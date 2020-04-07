//
//  ModuleIntercator.swift
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
            let currencies = FinanceAsset.currenciesDataModel().map { $0.items }
            let crypto = FinanceAsset.cryptoDataModel().map { $0.items }
            
            currencies.forEach { (items) in
                self.allAssetList.append(contentsOf: items)
            }
            
            crypto.forEach { (items) in
                self.allAssetList.append(contentsOf: items)
            }
            
            self.allAssetList.sort { assetName(fromInternalCode: $0) < assetName(fromInternalCode: $1) }
            
            DispatchQueue.main.async {
                self.presenter.viewController.dataSourceDidChanged(animated: false)
            }
        }
    }
}
