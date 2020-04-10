//
//  ModulePresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import RWExtensions

final class QuickSearchPresenter: RWPresenter {
    
    var interactor: QuickSearchInteractor!
    var router: QuickSearchRouter!
    unowned var viewController: QuickSearchViewController!
    var launchOption: QuickSearch.LauchOption?
    
    var isSearching = false
    var filteredList = [String]()
    
    //MARK: View Lifecycle
    
    override func didLoad() {
        viewController.addTableView()
    }
    
    override func viewWillAppear() {
        viewController.performApearranceAnimation()
    }
    
    //MARK: UI Input
    
    override func handleInput(type: Int, context: Any?) {
        let input = QuickSearchViewController.InputType(rawValue: type)
        switch input {
            
        case .open:
            if let internalCode = (context as? String) {
                let code = internalCode.toFullcode()
                let name = assetName(fromInternalCode: internalCode)
                AnalyticsEvent.register(source: .quicksearch, key: RWAnalyticsEventAssetOpened, context: code[0])
                router.routeTo(.toChart, context: [code, name])
            }
            
        default:
            break
        }
    }
}

//MARK: - VIEW->PRESENTER INTERFACE

extension QuickSearchPresenter {
    
    /// All existing assets.
    var assets: [String] {
        return isSearching ? filteredList : interactor.allAssetList
    }
    
    /// Perform search.
    func performSearch(text: String?) {
        
        // Check if the input text is valid.
        guard let searchText = text?.uppercased() else {
            isSearching = false
            return
        }
        
        // End serching if the input text is empty.
        if searchText == "" {
            isSearching = false
            return
        }
        
        // Begin searching otherwise.
        isSearching = true
        
        // Resigter analytics event.
        AnalyticsEvent.register(source: .quicksearch, key: RWAnalyticsEventSearched, context: searchText)
        
        // Filter data source on the background thread.
        DispatchQueue.global(qos: .userInteractive).async {
            self.filteredList = self.interactor.allAssetList.filter { $0.contains(searchText) }
            self.viewController.updateDataSource()
        }
    }
    
}
