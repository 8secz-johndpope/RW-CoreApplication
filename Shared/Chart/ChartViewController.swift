//
//  ModuleViewController.swift
//  RatesView
//
//  Created by Dennis Esie on 11/26/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import UIKit
import WebKit
import RWExtensions
import RWUserInterface
import NVActivityIndicatorView
import RWSession

final class ChartViewController: RWViewController {
    
    var presenter: ChartPresenter!
    
    private let typeSegmentedControl = UISegmentedControl(items: ["Profile", "Chart", "Financials"])
    private var intervalSegmentedControl: UISegmentedControl!
    private var styleSegmentedControl: UISegmentedControl!
    private var indicatorsArray: UIButton!
    private var priceView: UIView!
    private var loadingAnimationView: NVActivityIndicatorView!
    private var mainContainerView: UIView!
    private var segmentTypes = ["1", "0", "3", "2", "5"]
    
    private var profileContainerView: UIView!
    private var chartContainerView: UIView!
    private var financialsContainerView: UIView!
    
    private var webChartContainerView: UIView!
    private var webChartView: WKWebView!
    
    override func superDidLoad() {
        setDarkOnlyNavbar()
        view.backgroundColor = .background
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .link
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPage))
        
        #if !SECONVERTER
        let save = UIBarButtonItem(image: UIImage(named: "list"), style: .done, target: self, action: broadcastInput)
        save.tag = InputType.save.rawValue
        navigationItem.leftBarButtonItem = save
        #endif
    }
    
    //MARK: UI Input
    
    enum InputType: Int {
        case open = 0
        case delete = 1
        case more = 2
        case save = 3
    }
    
    override func dataSourceDidChanged(animated: Bool) {
        
    }
}

//MARK: - PRESENTER->VIEW INTERFACE

extension ChartViewController {
    
    //MARK: Subviews
    
    func initView() {

    }
    
    func addMainContainer() {
        if mainContainerView == nil {
            priceView = UIView()
            priceView.backgroundColor = .clear
            view.addSubview(priceView)
            priceView.horizontalConstraint(CGFloat.standartPageInset).topSafeConstraint().heightConstraint(50)

            let frame = CGRect(x: 0, y: 0, width: width, height: 50)
            loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: .presentedBackground, padding: 10)
            loadingAnimationView.startAnimating()
            priceView.addSubview(loadingAnimationView)
            
            let session = RWSession.sharedInstance()
            session.fetchSingleAsset(fullcode: presenter.lastShownAsset) { (price) in
                DispatchQueue.main.async {
                    self.loadingAnimationView.stopAnimating()
                    self.loadingAnimationView.removeFromSuperview()
                    self.loadingAnimationView = nil
                    let priceLabel = UILabel()
                    priceLabel.font = UIFont(name: "Futura-Bold", size: 24)
                    priceLabel.textColor = .text
                    self.priceView.addSubview(priceLabel)
                    priceLabel.frameConstraint()
                    priceLabel.text = "\(self.presenter.lastShownName) – \(String(price))"
                }
            }
            
            mainContainerView = UIView()
            mainContainerView.layer.cornerRadius = 8.5
            mainContainerView.clipsToBounds = true
            view.addSubview(mainContainerView)
            mainContainerView.horizontalConstraint(CGFloat.standartPageInset).topConstraint(toBot: priceView).bottomSafeConstraint()
        }
    }
    
    #if !SECONVERTER
    func openProfile() {
        typeSegmentedControl.selectedSegmentIndex = 0
    }
    #endif
    
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
            indicatorsArray.addTarget(self, action: #selector(changeIndicators), for: .touchDown)
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
            webChartView = WKWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            webChartContainerView.addSubview(webChartView)
            webChartView.frameConstraint()
            webChartView.topConstraint(isPad ? -20 : -10 * scale).bottomConstraint(41 * scale).leadingConstraint(-inset * scale).trailingConstraint(inset * scale)
            webChartContainerView.layer.borderColor = UIColor.background.cgColor
            webChartContainerView.layer.borderWidth = isPad ? 8 : 4
        }
        openWebChart()
    }
    
    func openWebChart() {
        let indicators = presenter.selectedIndicatorPaths()
        webChartView.openChart(presenter.lastShownAsset,
                               interval: presenter.interval,
                               style: presenter.style,
                               overrideDarkTheme: true,
                               indicators: indicators)
        
        if indicators.isEmpty {
            indicatorsArray.setTitle("+", for: .normal)
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let indicatorsArray = indicators.map { (indicator) -> String in
                    let splited = indicator.split(separator: "@", maxSplits: 1)
                    return String(splited[0])
                }
                let usedIndicators = indicatorsArray.joined(separator: ", ")
                DispatchQueue.main.sync {
                    self.indicatorsArray.setTitle(usedIndicators, for: .normal)
                }
            }
        }
    }
}

extension ChartViewController {
    
    @objc private func changeIndicators() {
        let indicatorsVC = ChartIndicatorsViewController()
        indicatorsVC.presenter = presenter
        navigationController?.pushViewController(indicatorsVC, animated: true)
    }
    
    @objc private func changeStyle() {
        let selectedIndex = styleSegmentedControl.selectedSegmentIndex
        let style = Int(segmentTypes[selectedIndex])!
        AnalyticsEvent.register(source: .chart, key: RWAnalyticsEventChartStyleChanged, context: String(style))
        presenter.style = style
        presenter.stylelIndex = selectedIndex
        openWebChart()
    }
    
    @objc private func changeInterval() {
        let selectedIndex = intervalSegmentedControl.selectedSegmentIndex
        let interval = intervalSegmentedControl.titleForSegment(at: selectedIndex)!
        AnalyticsEvent.register(source: .chart, key: RWAnalyticsEventChartIntervalChanged, context: String(interval))
        presenter.interval = interval
        presenter.intervalIndex = selectedIndex
        openWebChart()
    }
    
    //MARK: FINANCIALS
    
    #if !SECONVERTER
    func openFinancials() {
        typeSegmentedControl.selectedSegmentIndex = 2
    }
    #endif
    
}
