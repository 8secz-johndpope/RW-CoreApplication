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
    
    private var segmentTypes = ["1", "0", "3", "2", "5"]
    
    @autosaved(key: "interval", defaultValue: "1D")
    var interval: String
    
    @autosaved(key: "intervalIndex", defaultValue: 3)
    var intervalIndex: Int
    
    @autosaved(key: "style", defaultValue: 1)
    var style: Int
    
    @autosaved(key: "stylelIndex", defaultValue: 1)
    var stylelIndex: Int
    
    @autosaved(key: "lastShownAsset", defaultValue: "NASDAQ:AAPL")
    var lastAsset: String
    
    @autosaved(key: "lastShownName", defaultValue: "Apple Inc")
    var lastName: String
    
    @autosaved(key: "indicatorsMask", defaultValue: Array(repeating: false, count: 61))
    var indicatorsMask: [Bool]
    
    //MARK: View Lifecycle
    
    override func didLoad() {
        if let code = launchContext as? [String] {
            lastAsset = code[0]
            lastName = code[1]
        }
    }
    
    override func interactorDidLoadData() {
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
            
        case .indicators:
            router.routeTo(.toIndicators)
            
        default:
            break
        }
    }
    
}

//MARK: - PRESENTER->VIEW INTERFFACE

extension ChartPresenter {
    
    func indicatorNames() -> [String] {
        return interactor.availableIndicators.map {
            String($0.split(separator: "@", maxSplits: 1)[0])
        }
    }
    
    func selectedIndicatorPaths(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            let mask = self.indicatorsMask
            let result = self.interactor.availableIndicators.filter {
                mask[self.interactor.availableIndicators.firstIndex(of: $0)!]
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func changeStyle(index: Int) {
        guard let style = Int(segmentTypes[index]) else { return }
        AnalyticsEvent.register(source: .chart, key: RWAnalyticsEventChartStyleChanged, context: String(style))
        self.style = style
        self.stylelIndex = index
        viewController.openChart()
    }
    
    func changeInterval(value: String, at index: Int) {
        AnalyticsEvent.register(source: .chart, key: RWAnalyticsEventChartIntervalChanged, context: String(interval))
        self.interval = value
        self.intervalIndex = index
        viewController.openChart()
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




