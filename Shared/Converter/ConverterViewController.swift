//
//  ModuleViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import CoreData
import RWExtensions
import RWUserInterface

final class ConverterViewController: RWViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<String, NSManagedObject>
    
    var presenter: ConverterPresenter!
    
    var collectionView: UICollectionView!
    private lazy var collectionDataSource = makeCollectionCell()
    private var collectionDataSources = [DataSource]()
    private var loadedRates = [String : Bool]()
    private var isDeleting = false
    private var showHidden = false
    private let sections = ["Converter", "Hidden"]
    private var floatingButton: RWFloatingButton!
    
    private var draggedIndexPath: IndexPath?
    private var cellSnapshotImageView = UIImageView()
    private var reorderedAssetCode: String?
    
    override func superDidLoad() {
        setOpaqueNavbar()
        setFrostedTabBarAppearance()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .tint
        view.backgroundColor = .background
        tabBarController?.tabBar.tintColor = .tint
        
        #if TARGET_SC
        let circleImage = UIImage(named: "bg_circle")
        let smallCircle = UIImageView(image: circleImage)
        let smallCircleSize = CGSize(width: width, height: width)
        view.addSubview(smallCircle)
        smallCircle.sizeConstraints(smallCircleSize).bottomConstraint(width*0.15).trailingConstraint(width*0.75)
        let bigCircle = UIImageView(image: circleImage)
        let bigCircleSize = CGSize(width: width*1.25, height: width*1.25)
        view.addSubview(bigCircle)
        bigCircle.sizeConstraints(bigCircleSize).topConstraint(-width*0.2).leadingConstraint(-width*0.5)
        #endif
    }
    
    #if TARGET_SC
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    #endif
    
    /// React to device orientation change.
    override func viewWillTransition(toSize: CGSize) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            
            // Update cells blur background.
            self.addBlurToCollectionCells()
            
            // Update floating button position on device orientation change.
            self.floatingButton.switchToHide()
            self.floatingButton.hide()
        }
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case edit = 0
    }
    
    //MARK: UI Update
    
    override func dataSourceDidChanged(animated: Bool = true) {
        guard presenter.isEverythingLoaded else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            let sections = self.sections
            var collectionSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObject>()
            collectionSnapshot.appendSections(sections)
    
            let assets = self.presenter.activeList
            let fileteredAssets = assets.filter { $0.fullCode != self.reorderedAssetCode }
            var managedObjects = fileteredAssets.map { $0 as NSManagedObject }

            if let indexPath = self.draggedIndexPath, indexPath.section == 0 {
                let dummyObject = NSManagedObject()
                managedObjects.insert(dummyObject, at: indexPath.row)
            }
            
            collectionSnapshot.appendItems(managedObjects, toSection: sections[0])
            collectionSnapshot.appendItems(self.showHidden ? self.presenter.hiddenList : [], toSection: sections[1])
            
            self.collectionDataSource.apply(collectionSnapshot) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    self.addBlurToCollectionCells()
                }
            }
        }
    }
}


//MARK: - PRESENTER->VIEW INTERFACE

extension ConverterViewController {
    
    //MARK: Subviews
    
    func addCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = collectionDataSource
        collectionView.register(RWBigTitleHeaderView.self, forSupplementaryViewOfKind: RWBigTitleHeaderView.headerElementKind,
                                withReuseIdentifier: RWBigTitleHeaderView.reuseIdentifier)
        collectionView.register(ConverterCellView.self, forCellWithReuseIdentifier: ConverterCellView.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.topSafeConstraint().horizontalConstraint().bottomSafeConstraint()
        cellSnapshotImageView.isHidden = true
        cellSnapshotImageView.contentMode = .scaleToFill
        view.addSubview(cellSnapshotImageView)
        
        // Tap gesture for collection view reorder
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture(gesture:)))
        longTapGesture.minimumPressDuration = .defaultMinimumPressDuration
        collectionView.addGestureRecognizer(longTapGesture)
        
        // Create collection view header
        collectionDataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: RWBigTitleHeaderView.reuseIdentifier,
                                                                         for: indexPath) as! RWBigTitleHeaderView
            
            // Header label.
            header.textLabel.textColor = indexPath.section == 0 ? .text : .text
            header.textLabel.font = UIFont(name: "Futura-Bold", size: indexPath.section == 0 ? 30 : 15)
            let sectionName = NSLocalizedString(self.sections[indexPath.section], comment: "")
            header.textLabel.text = sectionName
            
            // Hidden section.
            if indexPath.section == 1 {
                
                // Set background view for header label.
                header.backgroung.backgroundColor = .systemBlue
                header.backgroung.layer.cornerRadius = 5.5
                header.backgroung.topConstraint(21).bottomConstraint(-9).widthConstraint(sectionName.count*12).leadingConstraint(30)
                
                // Show/Hide hidden assets.
                header.completion = {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    self.showHidden.invert()
                    self.dataSourceDidChanged()
                }
                
                // Hide if empty
                if self.presenter.hiddenList.isEmpty {
                    header.textLabel.textColor = .clear
                    header.backgroung.backgroundColor = .clear
                }
                
            // Active section.
            } else {
                header.backgroung.backgroundColor = .clear
                header.completion = nil
            }

            return header
        }
    }
    
    //MARK: Add Floating Icon
    
    func addFloatingButton() {
        floatingButton = RWFloatingButton(parent: self, collectionView: collectionView)
        floatingButton.switchToHide()
        floatingButton.hide()
    }
}

extension ConverterViewController {
    
    @objc func handleLongTapGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                selectedIndexPath.section == 0 else {
                    reorderedAssetCode = "LOCK"
                    return
            }
            
            floatingButton.show(hideMode: true)
            draggedIndexPath = selectedIndexPath
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            let cell = collectionView.cellForItem(at: selectedIndexPath) as! ConverterCellView
            reorderedAssetCode = (cell.representedObject as! CDWatchlistAssetAdapter).fullCode
            cellSnapshotImageView.image = cell.takeScreenshotOnMainThread()
            cellSnapshotImageView.frame = CGRect(x: 0, y: 0, width: width-CGFloat.standartDoublePageInset, height: .smallCellHeigh)
            cellSnapshotImageView.isHidden = false
            cellSnapshotImageView.center = gesture.location(in: view)
            
            // Highlight current cell
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.cellSnapshotImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            
            dataSourceDidChanged()
            
        case .changed:
            let location = gesture.location(in: view)
            cellSnapshotImageView.center = location
            
            if location.distance(to: floatingButton.removingCenter) < 40 {
                floatingButton.setHovered()
                draggedIndexPath = nil
                isDeleting = true
                dataSourceDidChanged()
            } else {
                isDeleting = false
                floatingButton.setUnhovered()
            
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)), reorderedAssetCode != "LOCK" else { break }
                if selectedIndexPath != draggedIndexPath {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    draggedIndexPath = selectedIndexPath
                    dataSourceDidChanged()
                }
            }
            
        case .ended:
            guard let code = reorderedAssetCode, reorderedAssetCode != "LOCK" else { return }
            let draggedAsset = presenter.activeList.filter { $0.fullCode == code }[0]
            let fromIndex = Int(draggedAsset.rowInConverter)
            draggedIndexPath = nil
            reorderedAssetCode = nil
            floatingButton.hide()
            
            if isDeleting {
                AnalyticsEvent.register(source: .converter, key: RWAnalyticsEventRemovedAsset, context: draggedAsset.fullCode)
                presenter.hideAsset(draggedAsset)
                isDeleting = false
                draggedIndexPath = nil
                reorderedAssetCode = nil
                cellSnapshotImageView.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.collectionView.reloadData() }
                return
            }
            
            guard collectionView.indexPathForItem(at: gesture.location(in: collectionView))?.section == 0 else {
                cellSnapshotImageView.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                    self.dataSourceDidChanged(animated: false)
                })
                return
            }
            
            if let toIndex = collectionView.indexPathForItem(at: gesture.location(in: collectionView))?.row {
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
                let cell = collectionView.cellForItem(at: selectedIndexPath!) as! ConverterCellView
                
                DispatchQueue.global(qos: .userInteractive).async {
                    let assets = self.presenter.activeList
                    
                    #if DEBUG //test
                    self.presenter.activeList.forEach { (asset) in
                        print("\(asset.fullCode) – \(asset.rowInConverter)")
                    }
                    print()
                    #endif
                    
                    // If cell dragged DOWN
                    if toIndex > fromIndex {
                        assets[fromIndex+1...toIndex].forEach { $0.rowInConverter &-= 1 }
                        draggedAsset.rowInConverter = Int16(toIndex)
                    }
                    
                    // If cell dragged UP
                    if toIndex < fromIndex {
                        assets[toIndex...fromIndex-1].forEach { $0.rowInConverter &+= 1 }
                        draggedAsset.rowInConverter = Int16(toIndex)
                    }
                    
                    AnalyticsEvent.register(source: .converter, key: RWAnalyticsEventReorder, context: code)
                    
                    // Save core data model
                    DispatchQueue.main.async {
                        let origin = cell.convert(CGPoint.zero, to: self.view)
                        let frame = CGRect(origin: origin, size: CGSize(width: cell.frame.width, height: cell.frame.height))
                        
                        // Highlight current cell
                        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                            self.cellSnapshotImageView.transform = .identity
                            self.cellSnapshotImageView.frame = frame
                        }, completion: { _ in
                            AppDelegate.saveContext()
                            self.cellSnapshotImageView.isHidden = true
                            self.dataSourceDidChanged(animated: false)
                        })
                    }
                }
                
            } else {
                cellSnapshotImageView.isHidden = true
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

extension ConverterViewController: UICollectionViewDelegate {
    
    //MARK: Cell Provider
    
    func makeCollectionCell() -> DataSource {
        return DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, asssetEntity in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConverterCellView.reuseIdentifier, for: indexPath) as! ConverterCellView

            cell.isInHiddenSection = indexPath.section == 1
            cell.index = indexPath.row
            cell.representedObject = asssetEntity as? CDWatchlistAssetAdapter
            cell.presenter = self.presenter
            cell.updateState()
            return cell
        })
    }
    
    //MARK: Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _ ) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(.smallCellHeigh))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .standartPageInset, bottom: 0, trailing: .standartPageInset)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
            
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
    
    private func addBlurToCollectionCells() {
        collectionView.subviews.forEach {
            if $0 is RWBlurredView { $0.removeFromSuperview() }
        }
        
        //DispatchQueue.global(qos: .userInteractive).async {
            let dataSource = self.presenter.activeList
            let count = dataSource.count
            if count == 0 { return }
            
            for i in 0...count-1 {
                let indexPath = IndexPath(row: i, section: 0)
                //DispatchQueue.main.async {
                    guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
                    let cellOrigin = cell.convert(CGPoint.zero, to: self.collectionView)
                    let inset = CGFloat.standartInset
                    let size = CGSize(width: cell.frame.width-(inset*2), height: cell.frame.height-(inset*2))
                    let frame = CGRect(origin: cellOrigin + Vector2D(inset), size: size)
                    let blurView = RWThirdBlurredView()
                    blurView.layer.cornerRadius = CGFloat.standartCornerRadius
                    blurView.clipsToBounds = true
                    blurView.frame = frame
                    self.collectionView.insertSubview(blurView, at: 0)
                //}
            }
        //}
    }
}
