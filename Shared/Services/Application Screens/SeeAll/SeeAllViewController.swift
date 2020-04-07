//
//  ModuleViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit

extension SeeAll {
    
    final class ViewController: BaseViewController {
        
        var presenter: Presenter!
        
        //MARK: - Properties
        
        private lazy var collectionDataSource = makeCollectionCell()
        private var collectionView: UICollectionView!
        var sectionToShow: SectionDataSourceItem!
        
        //MARK: - Construct
        
        /// Called automatically after vc's viewDidLoad(), but before presenter's didLoad() and interactor's initialDataCheck().
        override func onViewDidLoad() {
            sectionToShow = presenter.launchContext as? SectionDataSourceItem
            navigationController?.navigationBar.prefersLargeTitles = true
            title = sectionToShow.name
            view.backgroundColor = .systemBackground
            navigationController!.navigationBar.tintColor = UIColor(named: "pageLinkPrimary")
        }

        //MARK: - Transition
        
        /// Called automatically on view's transition.
        override func viewWillTransition(toSize: CGSize) {

        }
    
        //MARK: - UI Input
              
        /// UI Input tags
        /// Should be used with broadcastInput()
        enum InputType: Int {
            case addAsset = 0
            case openProfile = 1
            case openChart = 2
            case openFinancials = 3
            case delete = 4
        }
        
        //MARK: - UI Update
        
        /// Called once after presenter's interactorDidLoadData().
        /// Then called automatically each time interactor's dataSource changes.
        override func dataSourceDidChanged(isInitial: Bool) {
            var collectionSnapshot = NSDiffableDataSourceSnapshot<SectionDataSourceItem, AssetDataSourceItem>()
            collectionSnapshot.appendSections([sectionToShow])
            collectionSnapshot.appendItems(sectionToShow.assetInCollection?.allObjects as! [AssetDataSourceItem])
            collectionDataSource.apply(collectionSnapshot)
        }
    }
}

extension SeeAll.ViewController {
    
    //MARK: - Subviews
        
    func addCollectionView() {
        let layout = CollectionLayout()
        layout.superVC = self
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = collectionDataSource
        collectionView.register(Watchlist.ViewController.CollectionCell.self, forCellWithReuseIdentifier: CellID.watchlistDataCollection)
        view.addSubview(collectionView)
        collectionView.frameConstraint(tableInset)
    }

}

// MARK: - COLLECTION VIEWS

extension SeeAll.ViewController: WatchlistCellToViewController {
    
    //MARK: - Collection Cell
    
    func makeCollectionCell() -> UICollectionViewDiffableDataSource<SectionDataSourceItem, AssetDataSourceItem> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, assetDataSource in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.watchlistDataCollection, for: indexPath) as! Watchlist.ViewController.CollectionCell
            cell.viewControllerInterface = self
            cell.updateData(assetDataSource.asset!)
            return UICollectionViewCell()
        })
    }
    
    func didTapWith(_ context: Any?) {
        broadcastInput(0, context: context as! Asset)
    }
    
}

// MARK: - CONTEXT MENU

extension SeeAll.ViewController {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [unowned self] _ in
            let asset = self.sectionToShow.assetInCollection
            return self.makeContextMenu(context: asset)
        })
    }

    func makeContextMenu(context: Any) -> UIMenu {
        let viewProfile = UIAction(title: "Company Profile", image: nil) { [unowned self] _ in
            self.broadcastInput(InputType.openProfile.rawValue, context: context)
        }
        let viewChart = UIAction(title: "Price Chart", image: nil) { [unowned self] _ in
            self.broadcastInput(InputType.openChart.rawValue, context: context)
        }
        let viewFinancials = UIAction(title: "Financials", image: nil) { [unowned self] _ in
            self.broadcastInput(InputType.openFinancials.rawValue, context: context)
        }
        let delete = UIAction(title: "Delete", image: nil, attributes: .destructive) { [unowned self] _ in
            self.broadcastInput(InputType.delete.rawValue, context: context)
        }
        return UIMenu(title: "", children: [viewProfile, viewChart, viewFinancials, delete])
    }
 
}

