//
//  RatesCellView.swift
//  SEConverter
//
//  Created by Esie on 3/8/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface
import NVActivityIndicatorView

final class RatesCellView: RWInteractiveCollectionViewCell {

    private var displayLink: CADisplayLink?
    private var animationStartDate: Date?

    private let mainAssetView = UIView()
    private let starIconView = UIImageView()
    private let iconImageView = UIImageView()
    private let priceTextView = UILabel()
    private let nameLabel = UILabel()
    private let codeLabel = UILabel()
    private let changeLabel = UILabel()
    private var loadingAnimationView: NVActivityIndicatorView!
    
    private var cachedOldPrice = 0.0
    private var transitOldValue = 0.0
    private var transitNewValue = 0.0
    private var places = 2

    weak var viewController: RatesViewController!
    
    //MARK: Constructor
    
    override func constructView() {
        interactiveView.backgroundColor = .itemInteractive
        interactiveView.layer.cornerRadius = .standartCornerRadius
        interactiveView.clipsToBounds = true
        
        mainAssetView.backgroundColor = .itemBackground
        mainAssetView.layer.cornerRadius = .standartCornerRadius
        mainAssetView.clipsToBounds = true
        mainView.addSubview(mainAssetView)
        mainAssetView.frameConstraint(CGFloat.standartInset)
        
        iconImageView.setPlaceholder(withRadius: 5.5)
        iconImageView.contentMode = .scaleAspectFill
        mainAssetView.addSubview(iconImageView)
        iconImageView.topLeftConstraint(7.5).sizeConstraints(width: 28, height: 28)
        
        mainAssetView.addSubview(priceTextView)
        priceTextView.textColor = .white
        priceTextView.textAlignment = .right
        priceTextView.font = UIFont(name: "Futura", size: 28)
        priceTextView.horizontalConstraint(15).verticalConstraint()
        
        changeLabel.setPlaceholder()
        changeLabel.textAlignment = .center
        changeLabel.textColor = .white
        changeLabel.layer.cornerRadius = 3.5
        changeLabel.layer.masksToBounds = true
        changeLabel.font = UIFont(name: "Futura-Bold", size: 8.5)
        mainAssetView.addSubview(changeLabel)
        changeLabel.sizeConstraints(CGSize(width: 50, height: 11.5)).trailingConstraint(-14).bottomConstraint(-7.5)
        
        nameLabel.setPlaceholder()
        nameLabel.textColor = .text
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont(name: "Futura-Bold", size: 15)
        mainAssetView.addSubview(nameLabel)
        nameLabel.topConstraint(to: iconImageView).heightConstraint(15)
            .leadingConstraint(7.5, toTrail: iconImageView).trailingConstraint()
        
        codeLabel.textColor = .text
        codeLabel.font = UIFont(name: "Futura", size: 8)
        mainAssetView.addSubview(codeLabel)
        codeLabel.topConstraint(1.5, toBot: nameLabel).leadingConstraint(8.5, toTrail: iconImageView)
            .trailingConstraint().heightConstraint(8.5)
        
        addSubview(starIconView)
        starIconView.topConstraint(10).trailingConstraint(-10).sizeConstraints(CGSize(width: 15, height: 15))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showChart))
        mainAssetView.addGestureRecognizer(tapGesture)
        
        loadingAnimationView = NVActivityIndicatorView(frame: .zero, type: .ballBeat, color: UIColor.white.withAlphaComponent(0.5), padding: 25)
        mainAssetView.addSubview(loadingAnimationView)
        loadingAnimationView.verticalConstraint().widthConstraint(100).trailingConstraint()
    }

    //MARK: Update Data
    
    override func updateView(animated: Bool) {
        let asset = representedObject as! CDWatchlistAssetAdapter
        
        // Star icon for local currencies
        if asset.currencyToUSD == Locale.current.currencyCode {
            starIconView.image = UIImage(named: "star")
        } else {
            starIconView.image = nil
        }
        
        // Asset Icon
        if let data = asset.iconImage {
            iconImageView.image = UIImage(data: data)
        } else {
            iconImageView.image = nil
        }
        
        // Asset Full Name
        if let name = asset.name {
            nameLabel.releasePlaceholder()
            nameLabel.text = name == "United States dollar" ? "United States dollar (to Euro)" : name
        }
        
        // Asset Code
        codeLabel.text = asset.code == "USDUSD" ? "EURUSD" : asset.code
        codeLabel.releasePlaceholder()
        
        if viewController.presenter.loadMask[asset.fullCode] ?? false {
            loadingAnimationView.stopAnimating()
            
            // Asset Price
            if let price = asset.price {
                let newPrice = Double(truncating: price).rounded(places: asset.pricePlaces)
                cachedOldPrice = newPrice
                
                // Display price
                if animated {
                    setNewPriceAnimated(newPrice)
                
                // Update price
                } else {
                    priceTextView.text = String(newPrice)
                }
            }
            
            // Price change in percentage
            // Invert percent
            if asset.isCurrency {
                if asset.pricePercent > 0 {
                    changeLabel.text = "-\(String(asset.pricePercent))%"
                    changeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
                } else {
                    let percent = String(asset.pricePercent).replacingOccurrences(of: "-", with: "+")
                    changeLabel.text = "\(percent)%"
                    changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
                }
                
            // Display original
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
            loadingAnimationView.startAnimating()
            priceTextView.text = ""
            changeLabel.text = ""
            changeLabel.backgroundColor = .clear
        }
    }
}

extension RatesCellView {
    
    @objc private func showChart() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        AnalyticsEvent.register(source: .watchlist, key: RWAnalyticsEventAssetOpened, context: asset.fullCode)
        viewController.presenter.router.routeTo(.toChart, context: [asset.fullCode, asset.name])
    }
    
    private func setNewPriceAnimated(_ newValue: Double) {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        animationStartDate = Date()
        transitNewValue = newValue
        places = asset.pricePlaces
        DispatchQueue.main.async {
            if self.displayLink != nil {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateFrame))
            self.displayLink?.add(to: .main, forMode: .default)
        }
    }
    
    @objc private func updateFrame() {
        guard let asset = representedObject as? CDWatchlistAssetAdapter else { return }
        let elapsedTime = Date().timeIntervalSince(animationStartDate!)
        let transitionDuration = 0.5
        if elapsedTime > transitionDuration {
            displayLink?.invalidate()
            displayLink = nil
            transitOldValue = Double(truncating: asset.price ?? 0.0).rounded(places: places)
            cachedOldPrice = transitOldValue
        } else {
            let value = transitOldValue + (elapsedTime / transitionDuration * (transitNewValue - transitOldValue))
            transitOldValue = value
            priceTextView.text = String(transitOldValue.rounded(places: places))
        }
    }
}
