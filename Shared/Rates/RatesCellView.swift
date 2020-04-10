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
        
        // Main cell view with represented asset data.
        assetView.backgroundColor = .itemBackground
        assetView.layer.cornerRadius = .standartCornerRadius
        assetView.clipsToBounds = true
        mainView.addSubview(assetView)
        assetView.frameConstraint(CGFloat.standartInset)
        
        // Flag image for currencies and icon for stocks/cryptocurrencies.
        iconImageView.layer.cornerRadius = 5.5
        iconImageView.clipsToBounds = true
        assetView.addSubview(iconImageView)
        iconImageView.topLeftConstraint(7.5).sizeConstraints(width: 47.5, height: 32)
        
        // Price label.
        assetView.addSubview(priceTextLabel)
        priceTextLabel.textColor = .white
        priceTextLabel.textAlignment = .right
        priceTextLabel.font = UIFont(name: "Futura", size: 30)
        priceTextLabel.horizontalConstraint(15).verticalConstraint()
        
        // Price change in percantage label.
        changeLabel.textAlignment = .center
        changeLabel.textColor = .white
        changeLabel.layer.cornerRadius = 3.5
        changeLabel.layer.masksToBounds = true
        changeLabel.font = UIFont(name: "Futura-Bold", size: 8.5)
        assetView.addSubview(changeLabel)
        changeLabel.sizeConstraints(CGSize(width: 50, height: 11.5)).trailingConstraint(-14).bottomConstraint(-7.5)
        
        // Asset's name label.
        nameLabel.textColor = .text
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont(name: "Futura-Bold", size: 15.5)
        assetView.addSubview(nameLabel)
        nameLabel.topConstraint(to: iconImageView).heightConstraint(15)
            .leadingConstraint(7.5, toTrail: iconImageView).trailingConstraint()
        
        // Asset's code label.
        codeLabel.textColor = .text
        codeLabel.font = UIFont(name: "Futura", size: 9)
        assetView.addSubview(codeLabel)
        codeLabel.topConstraint(3.5, toBot: nameLabel).leadingConstraint(8.5, toTrail: iconImageView)
            .trailingConstraint().heightConstraint(8.5)
        
        // Start icon to show local currency.
        addSubview(starImageView)
        starImageView.topConstraint(10).trailingConstraint(-10).sizeConstraints(CGSize(width: 15, height: 15))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showChart))
        assetView.addGestureRecognizer(tapGesture)
        
        // Animation view for loading the price.
        let color = UIColor.white.withAlphaComponent(0.5)
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballBeat, color: color, padding: 25)
        assetView.addSubview(activityIndicatorView)
        activityIndicatorView.verticalConstraint().widthConstraint(100).trailingConstraint()
    }

    //MARK: Update Data
    
    override func updateView(animated: Bool) {
        let asset = representedObject as! CDWatchlistAssetAdapter

        // Star icon for local currencies.
        if asset.currencyToUSD == Locale.current.currencyCode {
            starImageView.image = UIImage(named: "star")
        } else {
            starImageView.image = nil
        }
        
        // Asset's icon.
        if let data = asset.iconImage {
            iconImageView.image = UIImage(data: data)
            
            if asset.isCrypto {
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.backgroundColor = .clear
            } else {
                iconImageView.contentMode = .scaleAspectFill
            }
            
        } else {
            iconImageView.image = nil
        }
        
        // Asset full name.
        if let name = asset.name {
            nameLabel.releasePlaceholder()
            nameLabel.text = name == "United States dollar" ? "United States dollar (to Euro)" : name
        }
        
        // Asset Code.
        codeLabel.text = asset.code == "USDUSD" ? "EURUSD" : asset.code
        codeLabel.releasePlaceholder()
        
        if viewController.presenter.loadMask[asset.fullCode] ?? false {
            activityIndicatorView.stopAnimating()
            
            // Asset Price.
            if let price = asset.price {
                let newPrice = Double(truncating: price).rounded(places: asset.pricePlaces)
                cachedOldPrice = newPrice
                
                // Display price.
                if animated {
                    setNewPriceAnimated(newPrice)
                
                // Update price.
                } else {
                    priceTextLabel.text = String(newPrice)
                }
            }
            
            // Price change in percentage.
            // Invert percent.
            if asset.isCurrency {
                if asset.pricePercent > 0 {
                    changeLabel.text = "-\(String(asset.pricePercent))%"
                    changeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
                } else {
                    let percent = String(asset.pricePercent).replacingOccurrences(of: "-", with: "+")
                    changeLabel.text = "\(percent)%"
                    changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
                }
                
            // Display original.
            } else {
                if asset.pricePercent > 0 {
                    changeLabel.text = "+\(String(asset.pricePercent))%"
                    changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
                } else {
                    changeLabel.text = "\(String(asset.pricePercent))%"
                    changeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
                }
            }
            
        } else {
            activityIndicatorView.startAnimating()
            priceTextLabel.text = ""
            changeLabel.text = ""
            changeLabel.backgroundColor = .clear
        }
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
