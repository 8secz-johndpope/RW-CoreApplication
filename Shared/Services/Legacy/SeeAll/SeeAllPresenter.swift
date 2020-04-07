//
//  ModulePresenter.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation

extension SeeAll {
    
    final class Presenter: BasePresenter {
        
        var interactor: Interactor!
        var router: Router!
        unowned var viewController: ViewController!
        var launchOptions: [Options]?
        var launchContext: Any?
        
        //MARK: - Presenter Properties
        
        
        //MARK: - View Lifecycle
        
        /// Aka viewDidLoad()
        /// Called automatically after vc's viewDidLoad() and view's constructController(), but before interactor's initialDataCheck()
        override func didLoad() {
            viewController.addCollectionView()
        }
        
        /// Called automatically after interactor's initialDataCheck()
        override func interactorDidLoadData() {
            
        }
        
        /// Aka viewWillAppear()
        /// Called automatically after vc's viewWillAppear()
        override func willAppear() {
           
        }
        
        /// Aka viewDidAppear()
        /// Called automatically after vc's viewDidAppear()
        override func didAppear() {
           
        }
        
        /// Aka viewWillDisappear()
        /// Called automatically after vc's viewWillDisappear()
        override func willDisappear() {
            
        }
        
        /// Aka viewDidDisappear()
        /// Called automatically after vc's viewDidDisappear()
        override func didDisappear() {
            
        }
        
        /// Called automatically after vc receives memory warning
        override func didReceiveMemoryWarning() {
                
        }
        
        //MARK: - UI Input
        
        /// Called automatically with view's broadcastInput()
        override func handleInput(type: Int, context: Any?) {
            let input = Watchlist.ViewController.InputType(rawValue: type)
            switch input {
                

                
            default:
                break
            }
        }
    }
}



