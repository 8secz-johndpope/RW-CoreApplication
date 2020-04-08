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
            router.routeTo(.toChart, context: context)
            
        default:
            break
        }
    }
}

//MARK: - VIEW->PRESENTER

extension QuickSearchPresenter {
    
    var assets: [String] {
        return isSearching ? filteredList : interactor.allAssetList
    }
    
    func performSearch(text: String?) {
        guard let searchText = text?.uppercased() else { isSearching = false; return }
        if searchText == "" { isSearching = false; return }
        isSearching = true
        DispatchQueue.global(qos: .userInteractive).async {
            AnalyticsEvent.register(source: .quicksearch, key: RWAnalyticsEventSearched, context: searchText)
            self.filteredList = self.interactor.allAssetList.filter { $0.contains(searchText) }
            self.viewController.dataSourceDidChanged()
        }
    }
    
}
