//
//  RatesCellView.swift
//  RatesView
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface
import NVActivityIndicatorView

final class RatesCellView: RWInteractiveCollectionViewCell {
    
    public static let reuseIdentifier = "RatesCell"
    
    private var displayLink: CADisplayLink?
    private var animationStartDate: Date?
    private var cachedOldPrice = 0.0
    private var transitOldValue = 0.0
    private var transitNewValue = 0.0
    private var places = 2
    
    private let assetView = UIView()
    private let starImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let priceTextLabel = UILabel()
    private let nameLabel = UILabel()
    private let codeLabel = UILabel()
    private let changeLabel = UILabel()
    private var activityIndicatorView: NVActivityIndicatorView!
    
    weak var viewController: RatesViewController!
    
    //MARK: Constructor
    
    override func constructView() {
        
        // Interactive background view used for reordering cells or for interaction with floating button.
        interactiveView.backgroundColor = .itemInteractive
        interactiveView.layer.cornerRadius = .standartCornerRadius
        interactiveView.clipsToBounds = true
        
    }

    //MARK: Update Data
    
    override func updateView(animated: Bool) {

    }
}

extension RatesCellView {
    
    /// Route to chart vc from the wathclist.
    @objc private func showChart() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        viewController.presenter.showChart(asset: asset)
    }
    
    /// Set new price animated with the display link.
    private func setNewPriceAnimated(_ newValue: Double) {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        animationStartDate = Date()
        transitNewValue = newValue
        places = asset.pricePlaces
        
        // Remove previous display link, if the cell was reused.
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        // Add new display link.
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    /// Fires each frame during the animated transition of the price.
    @objc private func updateFrame() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        
        let elapsedTime = Date().timeIntervalSince(animationStartDate!)
        let transitionDuration = 0.5
        
        // If elapsed time surpassed transition duration – end animation.
        if elapsedTime > transitionDuration {
            displayLink?.invalidate()
            displayLink = nil
            transitOldValue = Double(truncating: asset.price ?? 0.0).rounded(places: places)
            cachedOldPrice = transitOldValue
            
        // Else – calculate transition value each frame, based on the percantage of the elapsed time.
        } else {
            let value = transitOldValue + (elapsedTime / transitionDuration * (transitNewValue - transitOldValue))
            transitOldValue = value
            priceTextLabel.text = String(transitOldValue.rounded(places: places))
        }
    }
}
