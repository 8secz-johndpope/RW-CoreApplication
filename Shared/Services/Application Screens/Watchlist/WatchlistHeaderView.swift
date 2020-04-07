//
//  WatchlistHeaderView.swift
//  RatesView
//
//  Created by Dennis Esie on 11/30/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WatchlistCollectionHeaderView: UICollectionReusableView {
    
    static let headerElementKind = "header-element-kind"
    static let reuseIdentifier = "collection-supplementary-reuse-identifier"

    private let seeAllButton = UIButton()
    private let headerLabel = UILabel()
    private let realTimeButton = UIButton()
    private var section = WatchlistSection()
    private var animationLayer = CAShapeLayer()
    
    weak var presenter: Watchlist.Presenter!
    weak var viewController: Watchlist.ViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        headerLabel.textColor = .label
        headerLabel.font = .systemFont(ofSize: 20, weight: .bold)
        addSubview(headerLabel)
        headerLabel.heightConstraint(40).widthConstraint(200).bottomConstraint().leadingConstraint(36)
        
        seeAllButton.setTitle(" ", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        seeAllButton.titleLabel?.textAlignment = .left
        seeAllButton.setTitleColor(.label, for: .normal)
        seeAllButton.addTarget(self, action: #selector(showAll), for: .touchDown)
        addSubview(seeAllButton)
        seeAllButton.frameConstraint()
        
//        realTimeButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
//        realTimeButton.titleLabel?.textAlignment = .left
//        realTimeButton.setTitleColor(.secondaryLabel, for: .normal)
//        realTimeButton.addTarget(self, action: #selector(realTimeTapped), for: .touchDown)
//        addSubview(realTimeButton)
//        realTimeButton.trailingConstraint(-16).verticalConstraint().widthConstraint(100)
//
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10, y: 18.75), radius: 5, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
//        animationLayer = CAShapeLayer()
//        animationLayer.path = circlePath.cgPath
//        animationLayer.lineWidth = 3.0
//        realTimeButton.layer.addSublayer(animationLayer)
//        realTimeButton.startGlowing()
//
//        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.duration = 5.0
//        animation.autoreverses = true
//        animation.repeatCount = .greatestFiniteMagnitude
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        animationLayer.add(animation, forKey: "fade")
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setSection(_ section: WatchlistSection) {
        self.section = section
        headerLabel.text = section.title ?? "Section"
        
        if section.position == 0 {
            seeAllButton.isHidden = true
            realTimeButton.isHidden = true
        } else {
            seeAllButton.isHidden = false
            realTimeButton.isHidden = false
            animationLayer.shadowColor = section.position == 1 ? UIColor.systemOrange.cgColor : UIColor.systemGreen.cgColor
            animationLayer.shadowRadius = 3.5
            animationLayer.shadowOpacity = 1
            animationLayer.shadowOffset = .zero
            animationLayer.fillColor = section.position == 1 ? UIColor.systemOrange.cgColor : UIColor.systemGreen.cgColor
            realTimeButton.setTitle(section.position == 1 ? "Delayed" : "Real-Time", for: .normal)
        }
        
    }
    
    @objc private func showAll() {
        viewController.broadcastInput(5, context: section)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    @objc private func realTimeTapped() {
        let actionVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionVC.addAction(UIAlertAction(title: presenter.isRealtimeEnabled ? "Stop Real-Time" : "Start Real-Time",
                                         style: presenter.isRealtimeEnabled ? .destructive : .default, handler: { (_) in
            self.presenter.switchRealTime()
        }))
        
        actionVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        
        viewController.present(actionVC, animated: true)
    }
    
    
    
    
    
    
    
//    func setSection(_ entity: NSManagedObject) {
//        self.section = entity as! SectionDataSourceItem
//        animateArrow()
//        sectionTitleButton.setTitleColor(.label, for: .normal)
//        sectionTitleButton.contentHorizontalAlignment = .left
//        sectionTitleButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        sectionTitleButton.addTarget(self, action: #selector(tappedOnTitle), for: .touchDown)
//        sectionTitleButton.setTitle(section.name, for: .normal)
//        addSubview(sectionTitleButton)
//        sectionTitleButton.topConstraint(7.5).leadingConstraint(32.5).heightConstraint(14).widthConstraint(200)
//
//        sectionFoldButton.setTitle("❯", for: .normal)
//        sectionFoldButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        sectionFoldButton.setTitleColor(.label, for: .normal)
//        sectionFoldButton.addTarget(self, action: #selector(tappedOnTitle), for: .touchDown)
//        sectionFoldButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
//        addSubview(sectionFoldButton)
//        sectionFoldButton.topConstraint(7.5).leadingConstraint(14).heightConstraint(14).widthConstraint(14)
//    }
//
//    @objc private func tappedOnTitle() {
//        animateArrow()
//        let impactGenerator = UIImpactFeedbackGenerator()
//        impactGenerator.impactOccurred(intensity: 0.65)
//        presenter.foldSection(section)
//    }
//
//    func animateArrow() {
//        configureSeeAllButton()
//        UIView.animate(withDuration: 0.3) {
//            if self.section.isFolded {
//                self.sectionFoldButton.transform = .identity
//            } else {
//                self.sectionFoldButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
//            }
//        }
//    }
//
//    func configureSeeAllButton() {
//        //            if section.isFolded && (section.assetInCollection?.count ?? 0) > 2 {
//        //                seeAllButton.setTitle("See All", for: .normal)
//        //                seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
//        //                seeAllButton.setTitleColor(.label, for: .normal)
//        //                seeAllButton.addTarget(self, action: #selector(showAll), for: .touchDown)
//        //                addSubview(seeAllButton)
//        //                seeAllButton.topConstraint(7.5).trailingConstraint(14).heightConstraint(14).widthConstraint(100)
//        //            } else {
//        //                seeAllButton.removeFromSuperview()
//        //            }
//    }
//

}
