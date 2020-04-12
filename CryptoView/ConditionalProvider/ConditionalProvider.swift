//
//  RatesApplicationProvider.swift
//  CryptoView
//
//  Created by Esie on 4/9/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import RWUserInterface
import RWExtensions
import UIKit

enum ConditionalProvider {
    
    //MARK: Collection View Header
    
    static let quickSearchInset: CGFloat = (DEVICE_IS_NEW_SCREEN_TYPE ? -45.0 : -35.0) - CGFloat.portfolioSectionHeight
    static let selectorHeaderFont = UIFont(name: "Futura-Bold", size: 18)
    static let selectorTitle = UIFont(name: "Futura", size: 16)
    static let selectorTitleSecondary = UIFont(name: "Futura", size: 10)
    static let ratesCollectionContentInset = UIEdgeInsets(top: 45+CGFloat.portfolioSectionHeight, left: 0, bottom: 65, right: 0)
    static let ratesHeaderFont = UIFont(name: "Futura-Bold", size: 22)
    
    //MARK: Layout – CONVERTER
    
    static func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        // Create collection view layout.
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _ ) -> NSCollectionLayoutSection? in
        
            // Section layout.
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(.quadCellHeigh))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: .standartPageInset, bottom: 0, trailing: .standartPageInset)
            let section = NSCollectionLayoutSection(group: group)
            
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
    
    #if ENABLE_PORTFOLIO
    static func createPortfolioLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _ ) ->
            NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(.portfolioSectionHeight*0.8))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: .standartPageInset/2.5)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: .standartPageInset, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPaging
            return section

        })
        return layout
    }
    #endif
    
    
}
