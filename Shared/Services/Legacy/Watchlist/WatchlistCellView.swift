//
//  WatchlistCollectionViewCell.swift
//  RatesView
//
//  Created by Dennis Esie on 12/1/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit
import CoreModules

final class WatchlistCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "watchlist-cell-reuse-identifier"
    
    private var animationGradientLayer: CAGradientLayer?
    private var animationBlurEffect: UIVisualEffectView?
    private var propertyAnimator: UIViewPropertyAnimator?
    private var displayLink: CADisplayLink?
    private var animationStartDate: Date?
    // Views
    private let shadowView = UIView()
    private let mainAssetView = UIView()
    private let hoverView = UIView()
    // Images
    private let chartImageView = UIImageView()
    private let iconImageView = UIImageView()
    // Labels
    private let actionButton = UIButton(type: .roundedRect)
    private let historyTextView = UITextView()
    private let priceTextView = UITextView()
    private let nameLabel = UILabel()
    private let codeLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    
    private var gradientLayer: CAGradientLayer?
    
    private var cachedOldPrice = 0.0
    private var transitOldValue = 0.0
    private var transitNewValue = 0.0
    
    var priceHistory = Array(repeating: 0.0, count: 6)
    
    var viewControllerInterface: Watchlist.ViewController!
    var asset: CDWatchlistAssetAdapter!
    
    //MARK: - Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        shadowView.backgroundColor = .itemBackground
        shadowView.layer.cornerRadius = 12.5
        shadowView.setStandartShadow()
        addSubview(shadowView)
        shadowView.frameConstraint(5.5)
        
        mainAssetView.backgroundColor = .itemBackground
        mainAssetView.layer.cornerRadius = 10.5
        mainAssetView.clipsToBounds = true
        addSubview(mainAssetView)
        mainAssetView.frameConstraint(5.5)
        
        mainAssetView.addSubview(chartImageView)
        chartImageView.horizontalConstraint().bottomConstraint().topConstraint(50)
        
        iconImageView.setPlaceholder(withRadius: 12)
        iconImageView.contentMode = .scaleAspectFill
        mainAssetView.addSubview(iconImageView)
        iconImageView.topLeftConstraint(7.5).sizeConstraints(width: 24, height: 24)
        
        priceLabel.setPlaceholder()
        mainAssetView.addSubview(priceLabel)
        priceLabel.topConstraint(5.5, toBot: iconImageView).leadingConstraint(7.5).sizeConstraints(width: width * 0.65, height: 30)

        mainAssetView.addSubview(priceTextView)
        priceTextView.backgroundColor = .clear
        priceTextView.topConstraint(toBot: iconImageView).leadingConstraint(7.5).sizeConstraints(width: width * 0.7, height: 30)
        
        changeLabel.setPlaceholder()
        changeLabel.textAlignment = .center
        changeLabel.textColor = .white
        changeLabel.layer.cornerRadius = 3.5
        changeLabel.layer.masksToBounds = true
        changeLabel.font = .systemFont(ofSize: .scaled(9), weight: .bold)
        mainAssetView.addSubview(changeLabel)
        changeLabel.trailingConstraint(-7.5).leadingConstraint(5.5, toTrail: priceLabel).topConstraint(7.5, to: priceLabel).bottomConstraint(-7.5, to: priceLabel)
        
        codeLabel.textColor = .text
        codeLabel.font = .systemFont(ofSize: .scaled(8), weight: .bold)
        mainAssetView.addSubview(codeLabel)
        codeLabel.topConstraint(2.5, to: iconImageView).leadingConstraint(5.5, toTrail: iconImageView).trailingConstraint(-7.5).heightConstraint(8.5)
        
        nameLabel.setPlaceholder()
        nameLabel.textColor = .text
        nameLabel.numberOfLines = 0
        nameLabel.font = .systemFont(ofSize: .scaled(8), weight: .medium)
        mainAssetView.addSubview(nameLabel)
        nameLabel.topConstraint(2.5, toBot: codeLabel).leadingConstraint(5.5, toTrail: iconImageView).trailingConstraint(-7.5).heightConstraint(8.5)
        
        historyTextView.backgroundColor = .clear
        historyTextView.textColor = .textDetail
        historyTextView.font = .systemFont(ofSize: 10, weight: .bold)
        mainAssetView.addSubview(historyTextView)
        historyTextView.horizontalConstraint(10).bottomConstraint().topConstraint(height*0.42)
        
        hoverView.backgroundColor = .clear
        hoverView.layer.cornerRadius = 10.5
        hoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        addSubview(hoverView)
        hoverView.frameConstraint()

        actionButton.setImage(UIImage(named: "More"), for: .normal)
        actionButton.tintColor = .sideElement
        actionButton.addTarget(self, action:  #selector(tappedAction(sender:)), for: .touchDown)
        hoverView.addSubview(actionButton)
        actionButton.topConstraint(8).trailingConstraint(-17).sizeConstraints(width: 26, height: 26)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //historyTextView.textColor = traitCollection.userInterfaceStyle == .dark ? .lightGray : .darkGray
        if let data = asset.chartImage {
            chartImageView.image = UIImage(data: data)?
                .withTintColor(.itemContent/*traitCollection.userInterfaceStyle == .dark ? .darkGray : .lightGray*/)
        }
    }
    
    //MARK: Update Data
    
    func updateData(fromCollection: Bool = false) {
        
        // Icon Image
        if let data = asset.iconImage {
            iconImageView.image = UIImage(data: data)
        } else {
            iconImageView.image = nil
        }
        
        // Chart Image
        if let data = asset.chartImage {
            chartImageView.image = UIImage(data: data)?
                .withTintColor(traitCollection.userInterfaceStyle == .dark ? .darkGray : .lightGray)
        }
        
        // Asset Full Name
        if let name = asset.name {
            nameLabel.releasePlaceholder()
            nameLabel.text = name
        }
        
        // Asset Code
        codeLabel.text = asset.code
        codeLabel.releasePlaceholder()
        
        if viewControllerInterface.presenter.initialLoadMask[asset.fullCode] ?? false {
            
            // Asset Price
            if let price = asset.price {
                let newPrice = Double(truncating: price).rounded(places: asset.pricePlaces)
                if newPrice > 0 {
                    if !fromCollection {
                        
                        if newPrice > cachedOldPrice {
                            hoverView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                        } else if newPrice < cachedOldPrice  {
                            hoverView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                        } else {
                            hoverView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                        }
                        
                        UIView.animate(withDuration: 0.5) {
                            self.hoverView.backgroundColor = .clear
                        }
                        
                        updatePriceHistory(newPrice)
                    } else {
                        setRawPriceText(newPrice)
                        cachedOldPrice = newPrice
                    }
                    setNewPrice(newPrice)
                    priceLabel.releasePlaceholder()
                }
            } else {
                priceTextView.text = ""
                priceLabel.setPlaceholder()
            }
            
            // Price change in percentage
            let changeInPercent = asset.pricePercent
            if changeInPercent != 0.0 {
                if asset.pricePercent > 0 {
                    self.changeLabel.text = "+\(String(asset.pricePercent))%"
                    self.changeLabel.backgroundColor = .systemGreen
                } else {
                    self.changeLabel.text = "\(String(asset.pricePercent))%"
                    self.changeLabel.backgroundColor = .systemRed
                }
            }
            
        }
        
        priceHistory = viewControllerInterface.presenter.priceHistory[asset.fullCode] ?? Array(repeating: 0.0, count: 6)
        updateHistory()
    }
}

private extension WatchlistCollectionViewCell {
    
    func updatePriceHistory(_ newPrice: Double) {
        priceHistory.removeLast()
        priceHistory.insert(newPrice, at: 0)
        viewControllerInterface.presenter.priceHistory[asset.fullCode] = priceHistory
        updateHistory()
    }
    
    func updateHistory() {
        historyTextView.text = priceHistory.map { String($0) == "0.0" ? "" : String($0) }.joined(separator: "\n")
    }
    
    func setRawPriceText(_ newPrice: Double) {
        let priceString = String(newPrice)
        let attributedPrice = NSMutableAttributedString(string: priceString)
        let indexDistanceOfDot = priceString.indexDistance(of: ".")! + 2
        let baseLenght = indexDistanceOfDot + 1 > priceString.length ? indexDistanceOfDot : indexDistanceOfDot + 1
        
        // Base
        let baseRange = NSRange(location: 0, length: baseLenght)
        attributedPrice.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 23), range: baseRange)
    
        // Sub
        if baseLenght < priceString.length {
            let subRange = NSRange(location: baseLenght, length: priceString.length-baseLenght)
            attributedPrice.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: subRange)
            attributedPrice.addAttribute(.baselineOffset, value: NSNumber(value: 5.5), range: subRange)
        }
        
        let priceDifference = (newPrice - cachedOldPrice).rounded(places: asset.pricePlaces)
        let differenceLenght = priceDifference == 0 ? 0 : String(priceDifference)
            .replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "0", with: "")
            .replacingOccurrences(of: ".", with: "").length
        
        // Color
        if differenceLenght <= priceString.length {
            let color = priceDifference > 0 ? UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1) : UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1)
            let changeColorRange = NSRange(location: priceString.length-differenceLenght, length: differenceLenght)
            attributedPrice.addAttribute(.foregroundColor , value: color, range: changeColorRange)
            let unchangedColorRange = NSRange(location: 0, length: priceString.length-differenceLenght)
            attributedPrice.addAttribute(.foregroundColor , value: UIColor.label, range: unchangedColorRange)
        }
        
        priceTextView.attributedText = attributedPrice
    }
    
    func setNewPrice(_ newValue: Double) {
        animationStartDate = Date()
        self.transitNewValue = newValue
        displayLink = CADisplayLink(target: self, selector: #selector(updateTextAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func updateTextAnimation() {
        let elapsedTime = Date().timeIntervalSince(animationStartDate!)
        let transitionDuration = 1.0
        if elapsedTime > transitionDuration {
            displayLink?.invalidate()
            displayLink = nil
            transitOldValue = Double(truncating: asset.price ?? 0.0).rounded(places: asset.pricePlaces)
            setRawPriceText(transitOldValue)
            self.cachedOldPrice = transitOldValue
        } else {
            let value = transitOldValue + (elapsedTime / transitionDuration * (transitNewValue - transitOldValue))
            transitOldValue = value
            setRawPriceText(transitOldValue.rounded(places: asset.pricePlaces))
        }
    }
    
    @objc func tapped(sender: UIGestureRecognizer) {
        viewControllerInterface.didTapWith(asset)
    }
    
    @objc func tappedAction(sender: UIGestureRecognizer) {
//        let context = ContextMenuViewController()
//        context.title = "Watchlist"
//        context.buttons = [Button("View"),
//                           Button("Delete")]
//        ContextualMenu.main.show(viewControllerInterface, target: context, options:
//            ContextualMenu.Options(
//                containerStyle: ContextualMenu.ContainerStyle(backgroundColor: .itemBackground),
//                menuStyle: .minimal,
//                hapticsStyle: .medium
//        ))
    }
    
}

extension StringProtocol {
    func indexDistance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func indexDistance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}
