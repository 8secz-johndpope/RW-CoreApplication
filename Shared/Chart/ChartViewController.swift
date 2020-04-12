//
//  ChartViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import RWExtensions
import RWUserInterface
import RWSession

final class ChartViewController: RWViewController {
    
    var presenter: ChartPresenter!
    
    private let typeSegmentedControl = UISegmentedControl(items: ["Profile", "Chart", "Financials"])
    private var intervalSegmentedControl: UISegmentedControl!
    private var styleSegmentedControl: UISegmentedControl!
    private var indicatorsArray: UIButton!
    private var priceView: UIView!
    private var loadingAnimationView: RWActivityIndicatorView!
    private var mainContainerView: UIView!
    
    private var profileContainerView: UIView!
    private var chartContainerView: UIView!
    private var financialsContainerView: UIView!
    
    private var webChartContainerView: UIView!
    private var webChartView: ChartWebView!
    
    override func superDidLoad() {
        setDarkOnlyNavbar()
        view.backgroundColor = .background
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .link
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPage))
        
//        #if TARGET_CW || TARGET_CER || TARGET_CERPRO || TARGET_RW
//        let save = UIBarButtonItem(image: UIImage(named: "list"), style: .done, target: self, action: broadcastInput)
//        save.tag = InputType.save.rawValue
//        navigationItem.leftBarButtonItem = save
//        #endif
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case open = 0
        case delete = 1
        case more = 2
        case save = 3
        case indicators = 4
    }
    
    override func updateDataSource(animated: Bool) {
        
    }
}

//MARK: - PRESENTER->VIEW INTERFACE

extension ChartViewController {
    
    //MARK: Subviews
    
    func addMainContainer() {
        if mainContainerView == nil {
            priceView = UIView()
            priceView.backgroundColor = .clear
            view.addSubview(priceView)
            priceView.horizontalConstraint(CGFloat.standartPageInset).topSafeConstraint().heightConstraint(50)

            let frame = CGRect(x: 0, y: 0, width: width, height: 50)
            loadingAnimationView = RWActivityIndicatorView(frame: frame, type: .ballBeat, color: .presentedBackground, padding: 10)
            loadingAnimationView.startAnimating()
            priceView.addSubview(loadingAnimationView)
            
            let session = RWSession.sharedInstance()
            session.fetchSingleAsset(fullcode: presenter.lastAsset) { (price) in
                DispatchQueue.main.async {
                    self.loadingAnimationView.stopAnimating()
                    self.loadingAnimationView.removeFromSuperview()
                    self.loadingAnimationView = nil
                    let priceLabel = UILabel()
                    priceLabel.font = UIFont(name: "Futura-Bold", size: 24)
                    priceLabel.textColor = .text
                    self.priceView.addSubview(priceLabel)
                    priceLabel.frameConstraint()
                    priceLabel.text = "\(self.presenter.lastName) – \(String(price))"
                }
            }
            
            mainContainerView = UIView()
            mainContainerView.layer.cornerRadius = 8.5
            mainContainerView.clipsToBounds = true
            view.addSubview(mainContainerView)
            mainContainerView.horizontalConstraint(CGFloat.standartPageInset).topConstraint(toBot: priceView).bottomSafeConstraint()
        }
    }
    
    //MARK: Profile
    
    #if TARGET_CER || TARGET_CERPRO || TARGET_RW
    func openProfile() {
        typeSegmentedControl.selectedSegmentIndex = 0
    }
    #endif
    
    //MARK: Financials
    
    #if TARGET_CER || TARGET_CERPRO || TARGET_RW
    func openFinancials() {
        typeSegmentedControl.selectedSegmentIndex = 2
    }
    #endif
    
    //MARK: Chart
    
    func openChart() {
        typeSegmentedControl.selectedSegmentIndex = 1
        
        if chartContainerView == nil {
            chartContainerView = UIView()
            chartContainerView.backgroundColor = .background
            mainContainerView.addSubview(chartContainerView)
            chartContainerView.frameConstraint()
            
            //MARK: Interval Segmented Control
            
            let intervalLabel = UILabel()
            intervalLabel.text = "Interval"
            intervalLabel.textAlignment = .right
            intervalLabel.textColor = .white
            intervalLabel.font = UIFont(name: "Futura", size: 12)
            chartContainerView.addSubview(intervalLabel)
            intervalLabel.sizeConstraints(width: 75, height: 30).leadingConstraint().topConstraint(5)
            
            intervalSegmentedControl = UISegmentedControl(items: ["1H", "2H", "4H", "1D", "1W", "1M"])
            intervalSegmentedControl.selectedSegmentTintColor = .presentedBackground
            intervalSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            intervalSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
            intervalSegmentedControl.addTarget(self, action: #selector(changeInterval), for: .valueChanged)
            intervalSegmentedControl.selectedSegmentIndex = presenter.intervalIndex
            chartContainerView.addSubview(intervalSegmentedControl)
            intervalSegmentedControl.topConstraint(5).heightConstraint(30)
                .leadingConstraint(5, toTrail: intervalLabel).trailingConstraint(-5)
            
            //MARK: Style Segmented Control
            
            let styleLabel = UILabel()
            styleLabel.text = "Style"
            styleLabel.textAlignment = .right
            styleLabel.textColor = .white
            styleLabel.font = UIFont(name: "Futura", size: 12)
            chartContainerView.addSubview(styleLabel)
            styleLabel.sizeConstraints(width: 75, height: 30).leadingConstraint().topConstraint(5, toBot: intervalLabel)
            
            styleSegmentedControl = UISegmentedControl(items: ["0", "1", "2", "3", "4"])
            styleSegmentedControl.setImage(UIImage(named: "jap_1"), forSegmentAt: 0)
            styleSegmentedControl.setImage(UIImage(named: "bars_0"), forSegmentAt: 1)
            styleSegmentedControl.setImage(UIImage(named: "line_2"), forSegmentAt: 2)
            styleSegmentedControl.setImage(UIImage(named: "area_3"), forSegmentAt: 3)
            styleSegmentedControl.setImage(UIImage(named: "kg_5"), forSegmentAt: 4)
            styleSegmentedControl.selectedSegmentTintColor = .presentedBackground
            styleSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            styleSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
            styleSegmentedControl.addTarget(self, action: #selector(changeStyle), for: .valueChanged)
            styleSegmentedControl.selectedSegmentIndex = presenter.stylelIndex
            chartContainerView.addSubview(styleSegmentedControl)
            styleSegmentedControl.topConstraint(5, toBot: intervalSegmentedControl).heightConstraint(30)
                .leadingConstraint(5, toTrail: styleLabel).trailingConstraint(-5)
            
            //MARK: Indicator
            
            let indicatorsLabel = UILabel()
            indicatorsLabel.text = "Indicators"
            indicatorsLabel.textAlignment = .right
            indicatorsLabel.textColor = .white
            indicatorsLabel.font = UIFont(name: "Futura", size: 12)
            chartContainerView.addSubview(indicatorsLabel)
            indicatorsLabel.sizeConstraints(width: 75, height: 30).leadingConstraint().topConstraint(5, toBot: styleLabel)
            
            indicatorsArray = UIButton()
            indicatorsArray.backgroundColor = UIColor.background * 1.33
            indicatorsArray.layer.cornerRadius = 5.5
            indicatorsArray.layer.masksToBounds = true
            indicatorsArray.titleLabel?.font = .systemFont(ofSize: 14)
            indicatorsArray.tag = InputType.indicators.rawValue
            indicatorsArray.addTarget(self, action: broadcastInput, for: .touchDown)
            chartContainerView.addSubview(indicatorsArray)
            indicatorsArray.topConstraint(5, toBot: styleSegmentedControl).heightConstraint(30)
                .leadingConstraint(5, toTrail: styleLabel).trailingConstraint(-5)
   
            //MARK: Chart
            
            // Chart container
            webChartContainerView = UIView()
            webChartContainerView.layer.cornerRadius = 8.5
            webChartContainerView.clipsToBounds = true
            chartContainerView.addSubview(webChartContainerView)
            webChartContainerView.topConstraint(7, toBot: indicatorsLabel).bottomConstraint().horizontalConstraint()
            
            // Chart
            let isPad = traitCollection.userInterfaceIdiom == .pad
            let scale = 4 - UIScreen.main.scale
            let inset = CGFloat(isPad ? 25 : 15)
            webChartView = ChartWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            webChartContainerView.addSubview(webChartView)
            webChartView.frameConstraint()
            webChartView.topConstraint(isPad ? -20 : -10 * scale).bottomConstraint(41 * scale).leadingConstraint(-inset * scale).trailingConstraint(inset * scale)
            webChartContainerView.layer.borderColor = UIColor.background.cgColor
            webChartContainerView.layer.borderWidth = isPad ? 8 : 4
        }
        openWebChart()
    }
    
    func openWebChart() {
        #if FORCE_DISABLE_DARKMODE
        let overrideDarkTheme = true
        #else
        let overrideDarkTheme = true
        #endif
        
        presenter.selectedIndicatorPaths(completion: { (indicators) -> Void in
            let presenter = self.presenter!
            self.webChartView.openChart(presenter.lastAsset, presenter.interval, presenter.style, overrideDarkTheme, indicators)
            
            if indicators.isEmpty {
                self.indicatorsArray.setTitle("+", for: .normal)
            } else {
                DispatchQueue.global(qos: .userInteractive).async {
                    let indicatorsArray = indicators.map { String($0.split(separator: "@", maxSplits: 1)[0]) }
                    let usedIndicators = indicatorsArray.joined(separator: ", ")
                    DispatchQueue.main.async {
                        self.indicatorsArray.setTitle(usedIndicators, for: .normal)
                    }
                }
            }
        })
    }
}

// MARK: -

extension ChartViewController {
    
    @objc private func changeStyle() {
        let selectedIndex = styleSegmentedControl.selectedSegmentIndex
        presenter.changeStyle(index: selectedIndex)
    }
    
    @objc private func changeInterval() {
        let selectedIndex = intervalSegmentedControl.selectedSegmentIndex
        guard let interval = intervalSegmentedControl.titleForSegment(at: selectedIndex) else { return }
        presenter.changeInterval(value: interval, at: selectedIndex)

    }
    
}
