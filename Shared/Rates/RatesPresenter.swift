//
//  RatesPresenter.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import RWSession
import RWExtensions

final class RatesPresenter: RWPresenter {
    
    var interactor: RatesInteractor!
    var router: RatesRouter!
    unowned var viewController: RatesViewController!
    var launchOption: Rates.LauchOption?
    
    private var cachedSections: [CDWatchlistSectionAdapter]?
    private var cachedAssets: [String : CDWatchlistAssetAdapter]?
    private var cachedAssetsCharts = [String]()
    
    var loadMask = [String : Bool]()
    var priceHistory = [String : [Double]]()
    var isRealtimeEnabled = true
    
    //MARK: Lifecycle
    
    override func didLoad() {
        RWSession.sharedInstance().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatedData), name: .didUpdatedDataOutside, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recievedData), name: .didUpdatedAssetData, object: nil)
    }
    
    override func interactorDidLoadData() {
        
        // Configure view controller.
        viewController.addCollectionView()
        viewController.addQuickSearchBar()
        viewController.addFloatingButton()
        viewController.unfreezeInput()
        
        // Register analytics event with user assets.
        let assets = Array(self.allAssets.keys)
        DispatchQueue.global(qos: .background).async {
            let assets = (assets.map { $0.toPair() })
                .map { $0.replacingOccurrences(of: "USD", with: "$") }
                .map { $0.replacingOccurrences(of: "EUR", with: "€") }
                .map { $0.replacingOccurrences(of: "USD", with: "£") }
            AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventOpened, messages: assets)
        }
    }
    
    override func viewWillAppear() {
        viewController.performApearranceAnimation(for: viewController.collectionView)
    }
    
    //MARK: UI Input
    
    override func handleInput(type: Int, context: Any?) {
        let input = RatesViewController.InputType(rawValue: type)
        switch input {
            
        // Respond to user's tap on an asset.
        case .toChart:
            router.routeTo(.toChart, context: context)
        
        // Respond to user's tap on settings button.
        case .toSettings:
            router.routeTo(.toSettings)
        
        // Respond to user's tap on quick search bar.
        case .toQuickSearch:
            router.routeTo(.toQuickSearch)
            
        default:
            break
        }
    }
}


//MARK: - VIEW->PRESENTER INTERFFACE - MASTER

extension RatesPresenter {
    
    /// All watchlist sections.
    var sections: [WatchlistSection] {
        get {
            if let result = cachedSections {
                return result
            } else {
                let unsortedSections = interactor.dataSource.map { $0 as! CDWatchlistSectionAdapter }
                let sortedSections = unsortedSections.sorted { $0.position < $1.position }
                cachedSections = sortedSections.filter { !$0.isPortfolioSection }
                return cachedSections!
            }
        }
    }
    
    /// Updates all cached data.
    func updateData(completion: @escaping() -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.cachedSections = nil
            self.cachedAssets = [String : CDWatchlistAssetAdapter]()
            self.cacheAllAssets()
            DispatchQueue.main.async { completion() }
        }
    }
    
    /// All watchlist assets [Fullcode : CoreDataAsset]
    var allAssets: [Fullcode : CDWatchlistAssetAdapter] {
        get {
            if cachedAssets == nil {
                cachedAssets = [Fullcode : CDWatchlistAssetAdapter]()
                cacheAllAssets()
            }
            return cachedAssets!
        }
    }
    
    /// Navigates to the asset selector screen.
    func showAssetSelectorScreen(section: Int, context: Any) {
        switch section {
        case 0:
            router.routeTo(.addCurrency, context: context)
        case 1:
            router.routeTo(.addCrypto, context: context)
        default:
            break
        }
    }
    
    /// Dissmises the asset selector screen.
    func dissmisAssetSelectorScreen(type: FinanceAsset?) {
        
        // If user has added an asset.
        if let index = type?.rawValue,
            let targetIndex = viewController.draggedIndexPath?.row,
            let sectionAssets = sections[index-1].assets?.allObjects as? [CDWatchlistAssetAdapter] {
            
            // Get all assets from the targer section.
            let assets = sectionAssets.sorted { $0.positionInWatchlist < $1.positionInWatchlist }
            let newAsset = assets[assets.count-1]
            assets[targetIndex...assets.count-1].forEach { $0.positionInWatchlist &+= 1 }
            
            // Set to just added asset it's new positon index.
            newAsset.positionInWatchlist = Int16(targetIndex)
            
            // Save core data model
            AppDelegate.saveContext()
        }
        
        // Update view controller's collection view and session state.
        viewController.draggedIndexPath = nil
        viewController.dataSourceDidChanged(animated: false)
        RWSession.sharedInstance().reallocResources()
    }
    
    /// Removes one selected asset from the watchlist and from the core data model.
    func removeAsset(_ asset: CDWatchlistAssetAdapter) {
        let context = AppDelegate.persistentContainer.viewContext
        let type = asset.classType
        context.delete(asset)
        
        // Recalculate other assets position on the background queue.
        DispatchQueue.global(qos: .userInteractive).async {
            let index = type.rawValue
            if let sectionAssets = self.sections[index-1].assets?.allObjects as? [CDWatchlistAssetAdapter] {
                
                // Index of the removed asset.
                let targetIndex = Int(asset.positionInWatchlist)
                
                // All watchlist asset for current section sorted.
                let filtered = sectionAssets.filter { $0.internalFullCode != nil }
                let assets = filtered.sorted { $0.positionInWatchlist < $1.positionInWatchlist }
                
                // Update all other assets watchlist indexes.
                assets[targetIndex...assets.count-1].forEach { $0.positionInWatchlist &-= 1 }
                
                // Update all other assets converter indexes.
                let allAssets: [CDWatchlistAssetAdapter] = Array(self.allAssets.values)
                let filteredAssets = allAssets.filter { $0.internalFullCode != nil }
                let allAssetsSorted = filteredAssets.sorted { $0.rowInConverter < $1.rowInConverter }
                let indexInConverter = Int(asset.rowInConverter)
                let count = allAssetsSorted.count
                
                if indexInConverter != count {
                    allAssetsSorted[indexInConverter...count-1].forEach { $0.rowInConverter &-= 1 }
                }

                // Save core data model
                DispatchQueue.main.async {
                    AppDelegate.saveContext()
                    self.cacheAllAssets()
                }
            }
        }
    }
}

//MARK: - VIEW->PRESENTER INTERFFACE - PORTFOLIO

#if TARGET_CW

extension RatesPresenter {
    
    var portfolioSections: [CDPortfolioSectionAdapter] {
        return interactor.portfolioSections.sorted { $0.position < $1.position }
    }
    
}

#endif

//MARK: - INTERNAL - MASTER

extension RatesPresenter {
    
    /// Populate cache dictionary with all assets [Fullcode : Asset].
    private func cacheAllAssets() {
        sections.forEach { (sectionEntity) in
            sectionEntity.assets?.forEach {
                let asset = $0 as! CDWatchlistAssetAdapter
                cachedAssets?[asset.fullCode] = asset
            }
        }
    }
    
    /// Completely reload watchlist data.
    @objc private func updatedData() {
        interactor.initialDataSourceCheck()
        viewController.dataSourceDidChanged(animated: false)
    }
    
    /// Recieve an update notification and reload updated assets accordinly.
    @objc private func recievedData(_ notification: Notification) {
        if let info = notification.userInfo as? [String : AssetBridgeObject] {
            
            // Iterate over all updated assets.
            for assetFullcode in info.keys {
                
                // Get single updated asset.
                if let asset = self.allAssets[assetFullcode] {
                    
                    // Get asset bridge object.
                    let updatedAsset = info[assetFullcode]!
                    
                    // Update asset properties.
                    asset.pricePercent = updatedAsset.changeInPercent ?? 0.0
                    asset.price = updatedAsset.price ?? 0.0
                    asset.priceChange = updatedAsset.changeInPrice ?? 0.0
                    if let name = updatedAsset.name { asset.name = name }
                    if let icon = updatedAsset.icon { asset.iconImage = icon }
                    asset.hasNoIcon = updatedAsset.hasNoIcon
                    
                    // Set current asset as loaded.
                    loadMask[assetFullcode] = true
                }
            }
            
            // Save core data model.
            AppDelegate.saveContext()
            
            // Update collection view cells with updated assets on the main thread.
            DispatchQueue.main.async {
                
                // Get updated assets.
                let assets = Array(info.keys)
                
                // Get visible cells.
                self.viewController.collectionView.visibleCells.forEach {
                    
                    // Get each cell and cell's represented asset.
                    if let collectionCell = $0 as? RatesCellView, let asset = collectionCell.representedObject as? CDWatchlistAssetAdapter {
                        
                        // Update cell's view only if it's represented asset recieved an update in the current notification.
                        if assets.contains(asset.fullCode) {
                            collectionCell.updateView(animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UPDATE DATA NOTIFICATION - MASTER

extension Notification.Name {
    static let didUpdatedDataOutside = Notification.Name("didUpdatedDataOutside")
}

// MARK: - SESSION DELEGATE - MASTER

extension RatesPresenter: PPSessionDelegate {
    
    func didLoadAssets() {
        DispatchQueue.main.async {
            SceneDelegate.rates.floatingButton.show()
            let presenter = SceneDelegate.converter.presenter
            presenter?.isEverythingLoaded = true
            presenter?.interactorDidLoadData()
        }
    }
    
    func visibleAssetsMask() -> [Fullcode] {
        let visibleCells = viewController.collectionView.visibleCells.filter {
            ($0 as? RatesCellView)?.representedObject != nil
        }
        return visibleCells.map {
            (($0 as! RatesCellView).representedObject as! CDWatchlistAssetAdapter).fullCode
        }
    }
    
}
