//
//  WatchlistViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit
import CoreModules
import CoreData

extension Watchlist {
    
    final class ViewController: RWViewController {
        
        typealias Header = WatchlistCollectionHeaderView
        typealias DataSource = UICollectionViewDiffableDataSource<CDWatchlistSectionAdapter, NSManagedObject>
        
        var presenter: Presenter!

        private var collectionView: UICollectionView!
        private lazy var collectionViewDataSource = createCollectionCell()
        
        override func superDidLoad() {
            setInvisibleTabBarAppearance()
            setOpaqueNavbar()
            view.backgroundColor = .background
            navigationController?.navigationBar.tintColor = .tint
            tabBarController?.tabBar.tintColor = .tint
        
            let addAssetButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(broadcastInput(sender:)))
            addAssetButton.tag = InputType.pageOptions.rawValue
            navigationItem.rightBarButtonItem = addAssetButton
            
            #if !SECONVERTER
            let vc = IntroViewController()
            vc.modalPresentationStyle = .custom
            present(vc, animated: false)
            #endif
        }
        
        //MARK: UI Input
        
        enum InputType: Int {
            case pageOptions = 0
            case openProfile = 1
            case presentChart = 2
            case openFinancials = 3
            case delete = 4
            case collapseSection = 5
        }
        
        //MARK: UI Update
        
        override func dataSourceDidChanged(animated: Bool = true) {
            DispatchQueue.global(qos: .userInteractive).async { [presenter = self.presenter!] in
                var collectionSnapshot = NSDiffableDataSourceSnapshot<CDWatchlistSectionAdapter, NSManagedObject>()
                collectionSnapshot.appendSections(presenter.sections)
                presenter.sections.forEach { (sectionItem) in
                    if sectionItem.isPortfolioSection {
                        let sectionItems = sectionItem.portfolioItems?.allObjects as? [PortfolioItem] ?? []
                        let sortedItems = sectionItems.sorted { $0.position < $1.position }
                        collectionSnapshot.appendItems(sortedItems, toSection: sectionItem)
                    } else {
                        let sectionItems = sectionItem.assets?.allObjects as? [CDWatchlistAssetAdapter] ?? []
                        let filteredItems = sectionItem.isFolded ? sectionItems.filter { 0...1 ~= $0.positionInWatchlist} : sectionItems
                        let sortedItems = filteredItems.sorted { $0.positionInWatchlist < $1.positionInWatchlist }
                        collectionSnapshot.appendItems(sortedItems, toSection: sectionItem)
                    }
                }
                self.collectionViewDataSource.apply(collectionSnapshot, animatingDifferences: animated)
                #if !SECONVERTER
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    self.shiftCellsToParallax()
                }
                #endif
            }
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFFACE

extension Watchlist.ViewController {
    
    //MARK: Collection View
        
    func addCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
        collectionView.register(Header.self, forSupplementaryViewOfKind: Header.headerElementKind, withReuseIdentifier: Header.reuseIdentifier)
        collectionView.register(WatchlistCollectionViewCell.self, forCellWithReuseIdentifier: WatchlistCollectionViewCell.reuseIdentifier)
        
        #if ESCONVERTER
        collectionView.register(PortfolioCellView.self, forCellWithReuseIdentifier: PortfolioCellView.reuseIdentifier)
        #endif
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.horizontalConstraint().bottomSafeConstraint().topConstraint(50)
        
        // Tap gesture for collection view reorder
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture(gesture:)))
        longTapGesture.minimumPressDuration = .defaultMinimumPressDuration
        collectionView.addGestureRecognizer(longTapGesture)
        
        // Create collection view header
        collectionViewDataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseIdentifier,
                                                                         for: indexPath) as! Header
            header.setSection(self.presenter.sections[indexPath.section])
            header.viewController = self
            header.presenter = self.presenter
            return header
        }
    }
    
    //MARK: Update Visible Cells
    
    func updateCells(cellsFullcode: [String]) {
        collectionView.visibleCells.forEach {
            if let collectionCell = $0 as? WatchlistCollectionViewCell {
                if cellsFullcode.contains(collectionCell.asset.fullCode) {
                    collectionCell.updateData()
                }
            }
        }
    }
    
    func returnVisibleCells() -> [String] {
        let visibleAssetCells = collectionView.visibleCells.filter { $0 is WatchlistCollectionViewCell}
        return visibleAssetCells.map { ($0 as! WatchlistCollectionViewCell).asset.fullCode }
    }
    
    func selectCell(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    //MARK: Parallax View
    
    func shiftCellsToParallax() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
        collectionView.visibleCells.forEach {
            if let cellAsset = ($0 as? WatchlistCollectionViewCell)?.asset {
                
                if cellAsset.section?.position == 1 {
                    switch cellAsset.globalWatchlistIndex {
                    case 0: $0.transform = CGAffineTransform(translationX: width*0.5, y: height*0.45)
                    case 1: $0.transform = CGAffineTransform(translationX: width*0.2, y: -height*0.05)
                    case 2: $0.transform = CGAffineTransform(translationX: width*0.25, y: -height*0.05)
                    case 3: $0.transform = CGAffineTransform(translationX: width*0.2, y: height*0.15)
                    case 4: $0.transform = CGAffineTransform(translationX: width*0.05, y: height*0.25)
                    default: break
                    }
                } else if cellAsset.section?.position == 2 {
                    switch cellAsset.globalWatchlistIndex {
                    case 0: $0.transform = CGAffineTransform(translationX: width*0.1, y: -height*0.6)
                    case 1: $0.transform = CGAffineTransform(translationX: -width*0.5, y: -height*0.2)
                    default: break
                    }
                }
                
            } else {
                $0.transform = CGAffineTransform(translationX: 0, y: -300)
            }
        }
    }
    
    func endParallax() {
        for cell in collectionView.visibleCells {
            let index = (cell as? WatchlistCollectionViewCell)?.asset.globalWatchlistIndex ?? 0
            UIView.animate(withDuration: 0.85, delay: Double(index)*0.1, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            })
        }
    }
}

// MARK: - SEARCH

//extension Watchlist.ViewController: UISearchResultsUpdating, UISearchControllerDelegate {
//
//    func updateSearchResults(for searchController: UISearchController) {
//        if let searchText = searchController.searchBar.text {
//            //presenter.performSearch(text: searchText)
//        }
//    }
//
//    func didDismissSearchController(_ searchController: UISearchController) {
//        //presenter.endSearching()
//    }
//
//    func didPresentSearchController(_ searchController: UISearchController) {
//        UIView.animate(withDuration: 0.3) {
//            self.view.frame.origin.y -= 90
//        }
//    }
//
//}

//MARK: - COLLECTION VIEW EVENTS

extension Watchlist.ViewController: UICollectionViewDelegate {
    
    @objc func handleLongTapGesture(gesture: UILongPressGestureRecognizer) {
//        switch(gesture.state) {
//
//        case .began:
//            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
//            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
//
//        case .changed:
//            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//
//        case .ended:
//            collectionView.endInteractiveMovement()
//
//        default:
//            collectionView.cancelInteractiveMovement()
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        presenter.pauseSession()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        presenter.continueSession()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        presenter.continueSession()
    }
    
    func didTapWith(_ context: Any?) {
        broadcastInput(2, context: context)
    }

}

//MARK: - COLLECTION VIEW

extension Watchlist.ViewController {
    
    //MARK: Cell Provider
    
    private func createCollectionCell() -> DataSource {
        return DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, assetEntity in
            if assetEntity is CDWatchlistAssetAdapter {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as! WatchlistCollectionViewCell
                cell.viewControllerInterface = self
                cell.asset = assetEntity as? CDWatchlistAssetAdapter
                cell.updateData(fromCollection: true)
                return cell
            
            } else {
                #if !ESCONVERTER
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PortfolioCellView.reuseIdentifier,
                                                              for: indexPath) as! PortfolioCellView
                cell.viewController = self
                cell.currentSection = self.presenter.sections[0]
                cell.asset = assetEntity as? PortfolioItem
                cell.updateData(fromCollection: true)
                return cell
                #endif
            }
        })
    }
    
    //MARK: Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _ ) -> NSCollectionLayoutSection? in
            
            #if RATESVIEW_PRO || RATESVIEW_BASE || CRYPTOVIEW
            
            // Layout for portfolio section
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(165))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .standartPageInset, bottom: 16, trailing: .standartPageInset)
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40)),
                    elementKind: Header.headerElementKind,
                    alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
                
            // Layout for all other sections
            } else {
                
                let cellsInRow = 1.0 / Double(self.numberOfCellsInRow)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(CGFloat(cellsInRow)), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(135))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .standartPageInset, bottom: 0, trailing: .standartPageInset)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40)),
                    elementKind: Header.headerElementKind,
                    alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            
            }
            
            #else
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .pageInset, bottom: 0, trailing: .pageInset)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40)),
                elementKind: Header.headerElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
            
            #endif
            
        }, configuration: config)
        return layout
    }
}
