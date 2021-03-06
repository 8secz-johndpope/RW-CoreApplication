//
//  WatchlistViewController.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface
import RWSession
import CoreData

final class WatchlistViewController: RWViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<CDWatchlistSectionAdapter, NSManagedObject>
    
    private lazy var collectionViewDataSource = createCollectionCell()
    var presenter: WatchlistPresenter!
    var collectionView: UICollectionView!
    var draggedIndexPath: IndexPath?
    
    private var impactOccured = false
    private var isDeleting = false
    private var searchButton: UIButton!
    private var floatingButton: RWFloatingButton!
    private var cellSnapshot = UIImageView()
    private var reorderedAsset: String?
    private var settingsButton: UIButton!
    
    override func superDidLoad() {
        setOpaqueNavbar()
        setFrostedTabBarAppearance()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .tint
        view.backgroundColor = .background
        tabBarController?.tabBar.tintColor = .tint
        setBackground()
    }
    
    /// Sets view controller background.
    private func setBackground() {
        let circleImage = UIImage(named: "bg_circle")
        
        #if RATESVIEW
        // Bottom-Right small circle.
        let smallCircle = UIImageView(image: circleImage)
        let smallCircleSize = CGSize(width: width, height: width)
        view.addSubview(smallCircle)
        smallCircle.sizeConstraints(smallCircleSize).bottomConstraint(width*0.15).trailingConstraint(width*0.75)
        
        // Top-Left big circle.
        let bigCircle = UIImageView(image: circleImage)
        let bigCircleSize = CGSize(width: width*1.25, height: width*1.25)
        view.addSubview(bigCircle)
        bigCircle.sizeConstraints(bigCircleSize).topConstraint(-width*0.2).leadingConstraint(-width*0.5)
        #endif
    }
    
    /// React to device orientation change.
    override func viewWillTransition(toSize: CGSize? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            
            // Update cells blur background.
            self.setCellsBackground()
            
            // Update quick search button size.
            let inset = CGFloat.standartPageInset
            let frame = CGRect(x: inset, y: -50,width: self.width-(inset*2), height: 33.5)
            self.searchButton.frame = frame
            
            // Update floating button position on device orientation change.
            if self.isDeleting {
                self.floatingButton.switchToDeleting()
            } else {
                self.floatingButton.switchToAdding()
            }
        }
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case toChart = 1
        case toSettings = 2
        case toQuickSearch = 3
    }
    
    //MARK: UI Update
    
    override func dataSourceDidChanged(animated: Bool = true) {
        
        // Switch to the background queue to avoid performing calculation on the main thread.
        DispatchQueue.global(qos: .userInteractive).async { [presenter = self.presenter!] in
            var collectionSnapshot = NSDiffableDataSourceSnapshot<CDWatchlistSectionAdapter, NSManagedObject>()
            collectionSnapshot.appendSections(presenter.sections)
            
            for section in presenter.sections {
                
                // All assets in the current section.
                let assets = section.assets?.allObjects as? [CDWatchlistAssetAdapter] ?? []
                let sortedAssets = assets.sorted { $0.positionInWatchlist < $1.positionInWatchlist }
                
                // Remove selected asset if user is reordering it.
                let filteredAssets = sortedAssets.filter { $0.fullCode != self.reorderedAsset }
                var managedObjects = filteredAssets.map { $0 as NSManagedObject }

                // Insert empty cell if user is adding an asset or reordering it.
                if let indexPath = self.draggedIndexPath, indexPath.section == section.position {
                    let dummyObject = NSManagedObject()
                    managedObjects.insert(dummyObject, at: indexPath.row)
                }
                
                collectionSnapshot.appendItems(managedObjects, toSection: section)
            }
            
            self.collectionViewDataSource.apply(collectionSnapshot, animatingDifferences: animated) {
                
                // Update cell backgrounds.
                DispatchQueue.main.async { self.setCellsBackground() }
            }
        }
    }
}

//MARK: - PRESENTER->VIEW INTERFFACE

extension WatchlistViewController {
    
    //MARK: Add Collection View and Settings Button
    
    func addCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.isUserInteractionEnabled = false
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
        collectionView.register(RWBigTitleHeaderView.self, forSupplementaryViewOfKind: RWBigTitleHeaderView.headerElementKind,
                                withReuseIdentifier: RWBigTitleHeaderView.reuseIdentifier)
        collectionView.register(WatchlistCellView.self, forCellWithReuseIdentifier: WatchlistCellView.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.horizontalConstraint().bottomConstraint().topSafeConstraint()
        collectionView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 65, right: 0)
        collectionView.alpha = 0
        
        // Cell snapshot image view.
        cellSnapshot.isHidden = true
        cellSnapshot.contentMode = .scaleToFill
        view.addSubview(cellSnapshot)
 
        // Tap gesture for collection view reorder.
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture(gesture:)))
        longTapGesture.minimumPressDuration = .defaultMinimumPressDuration
        collectionView.addGestureRecognizer(longTapGesture)
        
        // Collection view header.
        collectionViewDataSource.supplementaryViewProvider = { [unowned self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: RWBigTitleHeaderView.reuseIdentifier,
                                                                         for: indexPath) as! RWBigTitleHeaderView
            let section = self.presenter.sections[indexPath.section]
            header.textLabel.textColor = .text
            header.textLabel.font = UIFont(name: "Futura-Bold", size: 30)
            header.textLabel.text = NSLocalizedString(section.title ?? "Section", comment: "")
            return header
        }
    }
    
    //MARK: Add Quick Search Bar
    
    func addQuickSearchBar() {
        searchButton = UIButton(type: .roundedRect)
        searchButton.backgroundColor = .searchBar
        searchButton.layer.cornerRadius = 6.5
        searchButton.layer.masksToBounds = true
        searchButton.setTitleColor(.textDetail, for: .normal)
        searchButton.setTitle(NSLocalizedString("Quick Search", comment: ""), for: .normal)
        searchButton.addTarget(self, action: broadcastInput, for: .touchDown)
        searchButton.tag = InputType.toQuickSearch.rawValue
        collectionView.addSubview(searchButton)
        viewWillTransition()
    }
    
    //MARK: Add Floating Icon
    
    func addFloatingButton() {
        floatingButton = RWFloatingButton(parent: self, collectionView: collectionView)
        floatingButton.delegate = self
    }
    
    //MARK: Collection Appearance Animation
    
    func unfreezeInput() {
        collectionView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.collectionView.transform = .identity
            self.collectionView.alpha = 1
        })
    }
}

//MARK: - FLOATING ICON DELEGATE

extension WatchlistViewController: RWFloatingButtonDelegate {
    
    /// Called when the user is tapping on floating button.
    func didTapped(floatingButton button: RWFloatingButton) {
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAddPressed)
        
        // Get index of the last asset.
        let assetCount = presenter.sections[0].assets!.count
        draggedIndexPath = IndexPath(row: assetCount, section: 0)
        
        // Scroll to the middle.
        let scrollIndexPath = IndexPath(row: assetCount-1, section: 0)
        collectionView.scrollToItem(at: scrollIndexPath, at: .centeredVertically, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            
            // Animate floating button movement.
            UIView.animate(withDuration: 0.33, animations: {
                
                // Check if a selected cell exists and move floating button to it's center. Will not if the target section is empty.
                if let cell = self.collectionView.cellForItem(at: scrollIndexPath) {
                    
                    // Calculcate cell center.
                    let cellCenter = cell.convert(CGPoint.zero, to: self.view)
                        + CGPoint(x: cell.frame.width/2, y: CGFloat.standartCellHeigh
                        + (CGFloat.standartCellHeigh/2))
                    
                    self.floatingButton.button.center = cellCenter
                    
                // If target section is empty, move floating button to the center of the view.
                } else {
                    self.floatingButton.button.center = self.view.center
                }
                
            // Create an empty cell.
            }, completion: { (_) in
                self.dataSourceDidChanged()
                
                // Show context screen.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    let cell = self.collectionView.cellForItem(at: self.draggedIndexPath!)!
                    let origin = cell.convert(CGPoint.zero, to: self.view)
                    let frame = CGRect(origin: origin, size: CGSize(width: cell.frame.width, height: cell.frame.height))
                    self.presenter.showAssetSelectorScreen(section: 0, context: frame)
                    self.floatingButton.button.center = self.floatingButton.currentCenter
                }
            })
        }
    }
    
    /// Called when the user is dragging the floating button over a collection view cell.
    func didLandOn(floatingButton button: RWFloatingButton, at indexPath: IndexPath) {
        
        // Check if the highlighted cell has changed.
        if indexPath != draggedIndexPath {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            draggedIndexPath = indexPath
            dataSourceDidChanged()
        }
    }
    
    /// Called when the user releases the floating button.
    func didEnd(floatingButton button: RWFloatingButton) {
        
        // Check if a cell was selected previously.
        if let section = draggedIndexPath?.section, let indexPath = draggedIndexPath {
            AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAddDragged)
            
            // Get target cell.
            let cell = collectionView.cellForItem(at: indexPath)!
            
            // Calculate frame of the target cell.
            let origin = cell.convert(CGPoint.zero, to: view)
            let frame = CGRect(origin: origin, size: CGSize(width: cell.frame.width, height: cell.frame.height))
            
            // Open asset selector screen animated from the target cell.
            presenter.showAssetSelectorScreen(section: section, context: frame)
        }
    }
    
    /// Called when the user released the floatin button outside of the collection view.
    func didCancel(floatingButton button: RWFloatingButton) {
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAddCanceled)
        draggedIndexPath = nil
        dataSourceDidChanged()
    }
    
}

//MARK: - COLLECTION VIEW REORDER + QUICK BAR ANIMATION

extension WatchlistViewController: UICollectionViewDelegate {
    
    // Handle tap gesture for collection view reorder.
    @objc private func handleLongTapGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            
            // Get selected indexpath.
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            draggedIndexPath = selectedIndexPath
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            // Get selected cell.
            let cell = collectionView.cellForItem(at: selectedIndexPath) as! WatchlistCellView
            
            // Save selected cell's asset's code.
            reorderedAsset = (cell.representedObject as! CDWatchlistAssetAdapter).fullCode
            
            // Configure selected cell snapshot.
            cellSnapshot.image = cell.takeScreenshotOnMainThread()
            cellSnapshot.frame = CGRect(x: 0, y: 0, width: width-CGFloat.standartDoublePageInset, height: .standartCellHeigh)
            cellSnapshot.isHidden = false
            cellSnapshot.center = gesture.location(in: view)
            
            // Highlight current cell snapshot appearance.
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.cellSnapshot.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            
            // Update collection view data source.
            dataSourceDidChanged()
            
            // Switch floating button to deleting state.
            floatingButton.switchToDeleting()
            
        case .changed:
            
            // Get gesture location and set cell snapshot at it.
            let location = gesture.location(in: view)
            cellSnapshot.center = location
            
            // Check if snapshot if hovering the delete floating button.
            let detectionRadius: CGFloat = 40.0
            if location.distance(to: floatingButton.removingCenter) < detectionRadius {
                floatingButton.setHovered()
                draggedIndexPath = nil
                isDeleting = true
                dataSourceDidChanged()
            } else {
                isDeleting = false
                floatingButton.setUnhovered()
                
                // Get selected indexpath.
                guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
                
                // Check if selected cell has changed.
                if selectedIndexPath != draggedIndexPath {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    draggedIndexPath = selectedIndexPath
                    dataSourceDidChanged()
                }
            }
 
        case .ended:
            
            // Animate floating button to the initial state.
            floatingButton.setUnhovered()
            
            // Check if a cell was selected previously and dragged asset for it exists.
            guard let code = reorderedAsset, let draggedAsset = presenter.allAssets[code] else {
                return
            }
            
            // Check if dragged asset is being deleted.
            if isDeleting {
                
                // Submit an analytics event folowing the removal of an asset.
                AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventRemovedAsset, context: draggedAsset.fullCode)
                
                // Get local and remiving asset's cyrrency.
                let localCurrency = Locale.current.currencyCode
                let deletingCurrency = draggedAsset.currencyToUSD
                
                // Return to the normal state.
                isDeleting = false
                draggedIndexPath = nil
                reorderedAsset = nil
                floatingButton.switchToAdding()
                cellSnapshot.isHidden = true
                
                // Check if the removing asset is the local or if its usd. Keep asset if true.
                if deletingCurrency == localCurrency || deletingCurrency == "USD" {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    dataSourceDidChanged()
                } else {
                    presenter.removeAsset(draggedAsset)
                }
                
                return
            }
            
            // Switch floating button back to adding mode.
            isDeleting = false
            draggedIndexPath = nil
            reorderedAsset = nil
            floatingButton.switchToAdding()
            
            // Get initial asset's index.
            let fromIndex = Int(draggedAsset.positionInWatchlist)
            
            // Get asset's type.
            let fromType = draggedAsset.classType.rawValue

            // Check and get target asset's index and target asset's type. Fails if a selected cell was dragged outside of the collection view.
            if let toIndex = collectionView.indexPathForItem(at: gesture.location(in: collectionView))?.row,
                let toType = collectionView.indexPathForItem(at: gesture.location(in: collectionView))?.section {
                
                // Get selected indexpath.
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
                let cell = collectionView.cellForItem(at: selectedIndexPath!) as! WatchlistCellView
                
                // Switch to the background queue to avoid performing calculation on the main thread.
                DispatchQueue.global(qos: .userInteractive).async {
                    
                    // Perform position calculation only if source and target sections are the same.
                    if fromType == toType+1 {
                        let sectionAssets = self.presenter.sections[fromType-1].assets!.allObjects as! [CDWatchlistAssetAdapter]
                        let assets = sectionAssets.sorted { $0.positionInWatchlist < $1.positionInWatchlist }
                        
                        // If cell was dragged DOWN.
                        if toIndex > fromIndex {
                            assets[fromIndex+1...toIndex].forEach { $0.positionInWatchlist &-= 1 }
                            draggedAsset.positionInWatchlist = Int16(toIndex)
                        }
                        
                        // If cell was dragged UP.
                        if toIndex < fromIndex {
                            assets[toIndex...fromIndex-1].forEach { $0.positionInWatchlist &+= 1 }
                            draggedAsset.positionInWatchlist = Int16(toIndex)
                        }
                        
                        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventReorder, context: code)
                        
                        // Save core data model.
                        DispatchQueue.main.async {
                            let origin = cell.convert(CGPoint.zero, to: self.view)
                            let frame = CGRect(origin: origin, size: CGSize(width: cell.frame.width, height: cell.frame.height))
                            
                            // Highlight current cell.
                            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                                self.cellSnapshot.transform = .identity
                                self.cellSnapshot.frame = frame
                                
                            // Update collection view data source and hide selected cell snapshot.
                            }, completion: { _ in
                                AppDelegate.saveContext()
                                self.cellSnapshot.isHidden = true
                                self.dataSourceDidChanged(animated: false)
                            })
                        }
                    
                    // If source and target sections are NOT the same. Update collection view data source without reorder calculations.
                    } else {
                        DispatchQueue.main.async {
                            self.cellSnapshot.isHidden = true
                            self.dataSourceDidChanged(animated: false)
                        }
                    }
                }
                
            // If user dragged a cell outside of the collection view. Update collection view data source without reorder calculations.
            } else {
                cellSnapshot.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    self.dataSourceDidChanged(animated: false)
                })
            }

        default:
            break
        }
    }
}

//MARK: - COLLECTION VIEW

extension WatchlistViewController {
    
    //MARK: Cell Provider
    
    private func createCollectionCell() -> DataSource {
        return DataSource(collectionView: collectionView, cellProvider: { [unowned self] collectionView, indexPath, assetEntity in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCellView.reuseIdentifier,
                                                          for: indexPath) as! WatchlistCellView
            cell.viewController = self
            cell.isEmptyCell = !(assetEntity is CDWatchlistAssetAdapter)
            cell.representedObject = assetEntity as? CDWatchlistAssetAdapter
            cell.updateState()
            return cell
        })
    }
    
    //MARK: Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        // Create colleciton view layout.
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _ ) -> NSCollectionLayoutSection? in
        
            // Section layout.
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(.quadCellHeigh))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .standartPageInset, bottom: 0, trailing: .standartPageInset)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            
            // Section header layout.
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(.standartHeaderHeigh)),
                elementKind: RWBigTitleHeaderView.headerElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
            
        }, configuration: config)
        return layout
    }
    
    //MARK: Cell Blur
    
    /// Sets or updates cells background views.
    private func setCellsBackground() {
        
        // Remove all existing background views.
        collectionView.subviews.forEach {
            if $0 is RWBlurredView { $0.removeFromSuperview() }
        }
        
        // Get enumerated assets for the colleciton view.
        let dataSource = self.presenter.sections.enumerated()
        
        // Iterate over the sections.
        for (index, section) in dataSource {
            
            // Check section's assets count and return if its empty.
            let itemCount = section.assets?.count ?? 0
            if itemCount == 0 { return }
            
            // Iterate over the assets in current section.
            for i in 0...itemCount-1 {
                
                // Get sell at a given indexpath.
                let indexPath = IndexPath(row: i, section: index)
                guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
                
                // Calculate cell frame.
                let cellOrigin = cell.convert(CGPoint.zero, to: self.collectionView)
                let inset = CGFloat.standartInset
                let size = CGSize(width: cell.frame.width-(inset*2), height: cell.frame.height-(inset*2))
                let frame = CGRect(origin: cellOrigin + Vector2D(inset), size: size)
                
                // Create cells backgroubd view.
                let blurView = RWThirdBlurredView()
                blurView.layer.cornerRadius = CGFloat.standartCornerRadius
                blurView.clipsToBounds = true
                blurView.frame = frame
                self.collectionView.insertSubview(blurView, at: 0)
            }
        }
    }
}
