//
//  WatchlistPresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit

extension Watchlist {
    
    final class Presenter: RWPresenter {
        
        var interactor: Interactor!
        var router: Router!
        unowned var viewController: ViewController!
        var launchOptions: [Options]?
        var launchContext: Any?
        
        private var cachedSections: [CDWatchlistSectionAdapter]?
        private var cachedAssets: [String : CDWatchlistAssetAdapter]?
        private var numberOfInputs: UInt16 = 0
        private var cachedAssetsCharts = [String]()
        
        var initialLoadMask = [String : Bool]()
        var priceHistory = [String : [Double]]()
        var isRealtimeEnabled = true
        
        //MARK: Lifecycle
        
        override func didLoad() {
            PPSession.global.delegate = self
        }
        
        override func interactorDidLoadData() {
            viewController.addCollectionView()
            //beginParallaxAnimation()
        }

        override func viewwillAppear() {
            viewController.performApearranceAnimation()
            NotificationCenter.default.addObserver(self, selector: #selector(updatedData), name: .didUpdatedDataOutside, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(recievedData(_:)), name: .didUpdatedAssetData, object: nil)
        }
        
        override func viewDidAppear() {
            numberOfInputs = 1
            continueSession(isImmediate: true)
        }

        override func viewWillDisappear() {
            pauseSession(isImmediate: true)
        }
        
        override func didReceiveMemoryWarning() {
            pauseSession()
        }
        
        override func thermalStateChanged(state: ProcessInfo.ThermalState) {
            switch state {
            case .critical, .serious:
                pauseSession()
            case .nominal:
                continueSession()
            default:
                break
            }
        }
        
        //MARK: UI Input
        
        override func handleInput(type: Int, context: Any?) {
            let input = Watchlist.ViewController.InputType(rawValue: type)
            switch input {
                
            case .presentChart:
                router.routeTo(.toChart, context: context)
                pauseSession()
                
            case .pageOptions:
                let position = CGPoint(x: viewController.view.frame.width-24, y: 53.5)
                viewController.showContextMenu(at: position,
                                               labels: ["Add Stock", "Add Currency", "Add Crypto"],
                                               callbacks: [{ self.router.routeTo(.addStock) },
                                                           { self.router.routeTo(.addCurrency) },
                                                           { self.router.routeTo(.addCrypto) }])
                
            case .collapseSection:
                let section = context as! WatchlistSection
                section.isFolded = !section.isFolded
                viewController.dataSourceDidChanged()
                
            default:
                break
            }
        }
    }
}

//MARK: - VIEW->PRESENTER INTERFFACE

extension Watchlist.Presenter {

    // All wathclist sections
    var sections: [WatchlistSection] {
        get {
            if let result = cachedSections {
                return result
            } else {
                let unsortedSections = interactor.dataSource.map { $0 as! CDWatchlistSectionAdapter }
                let sortedSections = unsortedSections.sorted { $0.position < $1.position }
                
                #if ARCONVERTER || SECONVERTER
                cachedSections = sortedSections.filter { !$0.isPortfolioSection }
                #else
                cachedSections = sortedSections
                #endif
                return cachedSections!
            }
        }
    }
    
    // Abort data update session
    func pauseSession(isImmediate: Bool = false) {
        if isImmediate {
            PPSession.global.releaseResources()
        } else {
            if numberOfInputs == 0 { PPSession.global.releaseResources() }
            numberOfInputs &+= 1
        }
    }
    
    // Relaunch data update session
    func continueSession(isImmediate: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: isImmediate ? .sessionImmediateReallocDelay() : .sessionStandartReallocDelay()) {
            if self.numberOfInputs > 0 {
                self.numberOfInputs &-= 1
                if self.numberOfInputs == 0 {
                    if self.isRealtimeEnabled {
                        PPSession.global.reallocResources()
                    }
                }
            }
        }
    }
    
    //
    func dataWasUpdatedOutside(completion: @escaping() -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.cachedSections = nil
            self.cachedAssets = [String : CDWatchlistAssetAdapter]()
            self.populateAllPresentedAssetsDictionary()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    //
    func addPortfolioItem() {
        let portfSection = sections[0]
        let index = portfSection.portfolioItems!.count
        let newAccountItem = PortfolioItem(context: AppDelegate.persistentContainer.viewContext)
        newAccountItem.isGeneral = false
        newAccountItem.position = Int16(index)
        newAccountItem.title = ""
        portfSection.addToPortfolioItems(newAccountItem)
        viewController.dataSourceDidChanged()
        viewController.selectCell(at: IndexPath(row: index, section: 0))
    }
    
    //
    func switchRealTime() {
        isRealtimeEnabled = !isRealtimeEnabled
        if isRealtimeEnabled {
            continueSession(isImmediate: true)
        } else {
            pauseSession(isImmediate: true)
        }
    }
    
    //
    func asyncLoadPrices(callback: @escaping() -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sections = self.interactor.dataSource.map { $0 as! CDWatchlistSectionAdapter }
            var isLoaded = true
            
            sections.forEach { (watchlistSection) in
                if !watchlistSection.isPortfolioSection {
                    watchlistSection.assets?.forEach {
                        let checkPrice = Double(truncating: ($0 as! CDWatchlistAssetAdapter).price ?? 0.0)
                        if checkPrice == 0 {
                            isLoaded = false
                        }
                    }
                }
            }
            
            if isLoaded {
                DispatchQueue.main.async {
                    PPSession.global.releaseResources()
                    callback()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                    self.asyncLoadPrices(callback: callback)
                }
            }
        }
    }
    
    // All presented assets [Fullcode : CoreDataAsset]
    var allPresentedAssets: [String : CDWatchlistAssetAdapter] {
        get {
            if cachedAssets == nil {
                cachedAssets = [String : CDWatchlistAssetAdapter]()
                populateAllPresentedAssetsDictionary()
            }
            return cachedAssets!
        }
    }
    
    func beginParallaxAnimation() {
        viewController.shiftCellsToParallax()
    }
    
    func endParallaxAnimation() {
        viewController.endParallax()
    }
}

//MARK: - INTERNAL

extension Watchlist.Presenter {
    
    private func populateAllPresentedAssetsDictionary() {
        sections.forEach { (sectionEntity) in
            sectionEntity.assets?.forEach {
                let asset = $0 as! CDWatchlistAssetAdapter
                cachedAssets?[asset.fullCode] = asset
            }
        }
    }
    
    @objc private func updatedData() {
        interactor.initialDataSourceCheck()
        viewController.dataSourceDidChanged(animated: false)
    }
    
    @objc private func recievedData(_ notification: Notification) {
        if let info = notification.userInfo as? [String : CoreModules.AssetBridgeObject] {
            for assetFullcode in info.keys {
                if let asset = self.allPresentedAssets[assetFullcode] {
                    let updatedAsset = info[assetFullcode]!
                    asset.pricePercent = updatedAsset.changeInPercent ?? 0.0
                    asset.price = updatedAsset.price ?? 0.0
                    asset.priceChange = updatedAsset.changeInPrice ?? 0.0
                    if let name = updatedAsset.name { asset.name = name }
                    if let icon = updatedAsset.icon { asset.iconImage = icon }
                    asset.hasNoIcon = updatedAsset.hasNoIcon
                    initialLoadMask[assetFullcode] = true
                    
                    if let chart = updatedAsset.chart {
                        if !cachedAssetsCharts.contains(assetFullcode) {
                            chart.toUIImage().processPixels(operation: { (pixel,_,_,_,_) -> (Color32?) in
                                return pixel.red > 110 ? .clear : Color32(150, 150, 180)
                            }) { (result) in
                                asset.chartImage = result?.pngData()
                                self.cachedAssetsCharts.append(assetFullcode)
                                DispatchQueue.main.async {
                                    self.viewController.updateCells(cellsFullcode: [assetFullcode])
                                }
                            }
                        }
                    }
                }
            }
            
            AppDelegate.saveContext()
            
            DispatchQueue.main.async {
//                let updatedAssetCodes = Array(info.keys)
//                Log.info(self, message: "Presenter recieved updated assets: \(updatedAssetCodes) \(String(describing: info[updatedAssetCodes[0]]!.price))")
                self.viewController.updateCells(cellsFullcode: Array(info.keys))
            }
        }
    }
}

extension Watchlist.Presenter: PPSessionDelegate {
    
    func visibleAssetsMask() -> [String] {
        return viewController.returnVisibleCells()
    }
    
}

extension Notification.Name {
    static let didUpdatedDataOutside = Notification.Name("didUpdatedDataOutside")
}
