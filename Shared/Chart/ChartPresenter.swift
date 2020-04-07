//
//  ModulePresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import RWExtensions

final class ChartPresenter: RWPresenter {
    
    var interactor: ChartInteractor!
    var router: ChartRouter!
    unowned var viewController: ChartViewController!
    var launchOption: Chart.LauchOption?
    
    @autosaved(key: "interval", defaultValue: "1D")
    var interval: String
    
    @autosaved(key: "intervalIndex", defaultValue: 3)
    var intervalIndex: Int
    
    @autosaved(key: "style", defaultValue: 1)
    var style: Int
    
    @autosaved(key: "stylelIndex", defaultValue: 1)
    var stylelIndex: Int
    
    @autosaved(key: "lastShownAsset", defaultValue: "NASDAQ:AAPL")
    var lastShownAsset: String
    
    @autosaved(key: "lastShownName", defaultValue: "Apple Inc")
    var lastShownName: String
    
    @autosaved(key: "indicatorsMask", defaultValue: Array(repeating: false, count: 61))
    var indicatorsMask: [Bool]
    
    //MARK: View Lifecycle
    
    override func didLoad() {
        if let code = launchContext as? [String] {
            lastShownAsset = code[0]
            lastShownName = code[1]
        }
    }
    
    override func interactorDidLoadData() {
        viewController.initView()
        viewController.addMainContainer()
        viewController.openChart()
    }
    
    override func viewWillAppear() {
        if launchOption == .fromTabBar {
            viewController.performApearranceAnimation()
        }
    }
    
    //MARK: UI Input
    
    override func handleInput(type: Int, context: Any?) {
        let input = ChartViewController.InputType(rawValue: type)
        switch input {
        
        case .save:
            router.routeTo(.toSaved)
            
        case .more:
            router.routeTo(.toOptions)
            
        default:
            break
        }
    }
    
    func indicatorName(forIndex: Int) -> String {
        guard interactor.totalIndicatorsCount <= interactor.totalIndicatorsCount else { return "Invalid Indicator Index" }
        let indicatorPath = interactor.availableIndicators[forIndex]
        return String(indicatorPath.split(separator: "@")[0])
    }
    
    func indicatorNames() -> [String] {
        return interactor.availableIndicators.map {
            String($0.split(separator: "@")[0])
        }
    }
    
    func selectedIndicatorPaths() -> [String] {
        return interactor.availableIndicators.filter { indicatorsMask[interactor.availableIndicators.firstIndex(of: $0)!] }
    }
}

//MARK: - INTERNAL

private extension ChartPresenter {
    
//    func deleteCurrentItem() {
//        let context = AppDelegate.persistentContainer.viewContext
//        let object = launchContext as! CDWatchlistAssetAdapter
//        context.delete(object)
//        AppDelegate.saveContext()
//        viewController.dismiss(animated: true)
//        NotificationCenter.default.post(.init(name: .didUpdatedDataOutside))
//    }
//
//    func openCurrentItem() {
//        viewController.dismiss(animated: true) { [unowned self] in
//            self.router.routeTo(.open, context: self.launchContext)
//        }
//    }
    
}




