//
//  AssetSelectorPresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import CoreData
import RWSession
import RWExtensions

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
            watchlistPresenter.dissmisAssetSelectorScreen(selectedType: self.selectedCellType)
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFFACE

extension AssetSelectorPresenter {
    
    /// Returns the current assets list depending on the selected type and search input.
    var currentList: [FinanceAsset.SourceSection] {
        get {
            
            // Get current assets list depending on the selected type.
            let list = getCurrentFullList()
            guard isSearching, !searchText.isEmpty else { return list }
            
            // Iterate through every section.
            var filteredSections = [FinanceAsset.SourceSection]()
            list.forEach { (section) in
                
                // Iterate through every asset in this section.
                let filtered = section.items.filter {
                    
                    // Filter asset by it's code and it's name.
                    let name = assetName(fromInternalCode: $0).uppercased()
                    return $0.contains(searchText) || name.contains(searchText)
                }
                
                // Create a new section with filtered assets and add it to the data source if its not empty.
                let newSection = FinanceAsset.SourceSection(name: section.name, source: section.source, items: filtered)
                if !filtered.isEmpty {
                    filteredSections.append(newSection)
                }
            }
            return filteredSections
        }
    }
    
    /// Perform search.
    func performSearch(text: String) {
        isSearching = true
        searchText = text.uppercased()
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventSearched, context: searchText)
        viewController.updateDataSource(animated: true)
    }
    
    /// End seraching.
    func endSearching() {
        isSearching = false
        searchText = ""
        viewController.updateDataSource(animated: true)
    }
    
    /// Adds an asset with the selected code to the wathclist.
    func addAsset(internalCode: InternalCode) {
        DispatchQueue.global(qos: .userInteractive).async {
            let source = internalCode.toSource()
            let type = assetType(fromSource: source)
            self.addAsset(type: type, internalCode: internalCode)
        }
    }
    
}

//MARK: - INTERNAL

extension AssetSelectorPresenter {
    
    /// Adds an asset to the watchlist.
    private func addAsset(type: FinanceAsset, internalCode: InternalCode) {
        
        // Get all assets to check if the new asset already exists in the wathclist.
        let allFullcodes: [Fullcode] = Array(SceneDelegate.rates.presenter.allAssets.keys)
        
        // Check if all assets are valid.
        let allAsets: [CDWatchlistAssetAdapter] = Array(SceneDelegate.rates.presenter.allAssets.values)
        let assetsFiltered = allAsets.filter { $0.internalFullCode != nil }
        
        // Register an analytics event.
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAddedAsset, context: internalCode)
        
        DispatchQueue.main.async {
            
            // Get asset's fullcode and check if it already exists.
            let fullCode = internalCode.toFullcode()
            if !allFullcodes.contains(fullCode) {
                
                self.selectedCellType = type
                
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
                
            } else {
                errorFeedback()
            }
            
            SceneDelegate.rates.floatingButton.hide()
            self.router.routeTo(.toParent)
        }
    }
    
    /// Changes asset class type.
    private func changeType(to: Int) {
        selectedIndex = to
        viewController.updateDataSource(animated: false)
    }
    
    /// Returns data model for the current asset class type.
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
