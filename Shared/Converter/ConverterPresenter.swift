//
//  ConverterPresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import RWExtensions

final class ConverterPresenter: RWPresenter {
    
    var interactor: ConverterInteractor!
    var router: ConverterRouter!
    unowned var viewController: ConverterViewController!
    var launchOption: Converter.LauchOption?
    var selectedCurrencyIndex: Int!
    var convertedAmounts = [String : Double]()
    var loadedRates = [String : Bool]()
    
    unowned var selectedCell: ConverterCellView!
    unowned var selectedAsset: CDWatchlistAssetAdapter!
    
    @serializable(key: "isEverythingLoaded", defaultValue: false)
    var isEverythingLoaded: Bool
    
    //MARK: View Lifecycle
    
    override func didLoad() {
        
    }
    
    override func interactorDidLoadData() {
        if isEverythingLoaded && viewController.collectionView == nil {
            viewController.addCollectionView()
            viewController.addFloatingButton()
            viewWillAppear()
        }
    }
    
    override func viewWillAppear() {
        viewController.performApearranceAnimation(for: viewController.collectionView)
        interactor.reloadData()
        viewController.updateDataSource()
    }
    
    //MARK: UI Input
    
    override func handleInput(type: Int, context: Any?) {
        let input = ConverterViewController.InputType(rawValue: type)
        switch input {
            
            
            
        default:
            break
        }
    }
}


//MARK: - PRESENTER->VIEW INTERFFACE

extension ConverterPresenter {
    
    var activeList: [CDWatchlistAssetAdapter] {
        get { return interactor.activeList.sorted { $0.rowInConverter < $1.rowInConverter } }
    }
    
    var hiddenList: [CDWatchlistAssetAdapter] {
        get { return interactor.hiddenList.sorted { $0.rowInConverter < $1.rowInConverter } }
    }
    
    func deselectAllCells() {
        for cell in viewController.collectionView.visibleCells {
            (cell as! ConverterCellView).setDeselected()
        }
    }
    
    func updateValue(_ value: Double) {
        let visibleCells = viewController.collectionView.visibleCells
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let cell = self.selectedCell, let asset = cell.representedObject as? CDWatchlistAssetAdapter else { return }
            
            let selectedRate = asset.converterPrice
            let selectedAmount = cell.transitNewValue
            let selectedInDollars = asset.isCrypto ? (selectedAmount * selectedRate) : (selectedAmount / selectedRate)
            AnalyticsEvent.register(source: .converter, key: RWAnalyticsEventConverted,
                                    messages: [String(selectedRate), String(selectedAmount), String(selectedInDollars)], context: asset.fullCode)
            
            for asset in self.activeList {
                let isCrypto = asset.isCrypto
                let currencyRate = asset.converterPrice
                let inCurrency = isCrypto ? selectedInDollars / currencyRate : selectedInDollars * currencyRate
                self.convertedAmounts[asset.internalFullCode!] = inCurrency.rounded(places: 2)
            }
            
            for cell in visibleCells {
                let currentCell = cell as! ConverterCellView
                let asset2 = currentCell.representedObject as! CDWatchlistAssetAdapter
               
                if let amount = self.convertedAmounts[asset2.internalFullCode!] {
                    if asset2.internalFullCode != asset.internalFullCode {
                        DispatchQueue.main.async { currentCell.setNewValue(amount) }
                    }
                }
            }
        }
    }
    
    func hideAsset(_ asset: CDWatchlistAssetAdapter) {
        AnalyticsEvent.register(source: .converter, key: RWAnalyticsEventRemovedAsset, context: asset.fullCode)
        let index = Int(asset.rowInConverter)
        asset.sectionInConverter = 1
        
        if index != activeList.count {
            activeList[index...activeList.count-1].forEach { $0.rowInConverter &-= 1 }
        }
        
        // Save core data model
        DispatchQueue.main.async {
            AppDelegate.saveContext()
            self.interactor.reloadData()
            self.viewController.updateDataSource()
        }
    }
    
    func unhideAsset(_ asset: CDWatchlistAssetAdapter) {
        asset.sectionInConverter = 0
        asset.rowInConverter = Int16(interactor.activeList.count)
        AppDelegate.saveContext()
        interactor.reloadData()
        viewController.updateDataSource()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.viewController.collectionView.reloadData()
        }
    }
}
