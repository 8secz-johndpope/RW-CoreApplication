//
//  ModulePresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import CoreData
import RWSession
import RWExtensions
import RWUserInterface

final class AssetSelectorPresenter: RWPresenter {
    
    var interactor: AssetSelectorInteractor!
    var router: AssetSelectorRouter!
    unowned var viewController: AssetSelectorViewController!
    var launchOption: AssetSelector.LauchOption?
    
    private var selectedIndex = 1
    private var isSearching = false
    private var selectedCellType: FinanceAsset?
    private var searchText = String()
    private var stocksDataModel: [FinanceAsset.SourceSection]!
    private var currenciesDataModel: [FinanceAsset.SourceSection]!
    private var cryptoDataModel: [FinanceAsset.SourceSection]!
    
    //MARK: View Lifecycle
    
    override func didLoad() {
        stocksDataModel = []
        currenciesDataModel = FinanceAsset.currenciesDataModel()
        cryptoDataModel = FinanceAsset.cryptoDataModel()
        viewController.addTableView()
        changeType(to: launchOption!.rawValue)
    }
    
    override func viewDidDisappear() {
        let watchlistPresenter = SceneDelegate.rates.presenter!
        watchlistPresenter.updateData() {
            #if SECONVERTER || CRYPTOVIEW
            watchlistPresenter.dissmisAssetSelectorScreen(type: self.selectedCellType)
            #else
            watchlistPresenter.continueSession(isImmediate: true)
            #endif
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFFACE

extension AssetSelectorPresenter {
    
    var currentList: [FinanceAsset.SourceSection] {
        get {
            let list = getCurrentFullList()
            guard isSearching else { return list }
            
            var filteredSections = [FinanceAsset.SourceSection]()
            list.forEach { (section) in
                
                let filtered = section.items.filter {
                    let name = assetName(fromInternalCode: $0).uppercased()
                    return $0.contains(searchText) || name.contains(searchText)
                }
                
                let newSection = FinanceAsset.SourceSection(name: section.name, source: section.source, items: filtered)
                if !filtered.isEmpty {
                    filteredSections.append(newSection)
                }
            }
            return filteredSections
        }
    }
    
    func performSearch(text: String) {
        isSearching = true
        searchText = text.uppercased()
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventSearched, context: searchText)
        viewController.dataSourceDidChanged(animated: true)
    }
    
    func endSearching() {
        isSearching = false
        searchText = ""
        viewController.dataSourceDidChanged(animated: true)
    }
    
    func addAsset(type: FinanceAsset, source: String, code: String) {
        let fullCode = (source + ":" + code).replacingOccurrences(of: "-", with: "")
        let internalCode = source + ":" + code
        let allFullcodes: [Fullcode] = Array(SceneDelegate.rates.presenter.allAssets.keys)
        let allAsets: [CDWatchlistAssetAdapter] = Array(SceneDelegate.rates.presenter.allAssets.values)
        let assetsFiltered = allAsets.filter { $0.internalFullCode != nil }
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAddedAsset, context: internalCode)
        
        if !allFullcodes.contains(fullCode) {
            selectedCellType = type
            let context = AppDelegate.persistentContainer.viewContext
            var sections = [WatchlistSection]()
            
            do {
                sections = try context.fetch(WatchlistSection.fetchRequest())
                let section = sections.filter { $0.title == type.getName() }[0]
                let position = Int16(assetsFiltered.count)
                section.addAsset(internalFullCode: internalCode, overrrideRowInConverter: position)
                AppDelegate.saveContext()
                
                let object = AssetBridgeObject(fullCode: fullCode, isDetailed: false)
                RWSession.sharedInstance().appendSession(with: [object])
                
            } catch let error as NSError {
                print("Could not fetch sections. \(error), \(error.userInfo)")
            }
        }
        
        SceneDelegate.rates.floatingButton.hide()
        resignCurrentContextController()
        router.routeTo(.toParent)
    }
}

//MARK: - INTERNAL

extension AssetSelectorPresenter {
    
    private func changeType(to: Int) {
        selectedIndex = to
        viewController.dataSourceDidChanged(animated: false)
    }
    
    private func getCurrentFullList() -> [FinanceAsset.SourceSection] {
        switch selectedIndex {
        case 0:
            return stocksDataModel
        case 1:
            return currenciesDataModel
        case 2:
            return cryptoDataModel
        default:
            return []
        }
    }
}
