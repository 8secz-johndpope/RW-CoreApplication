//
//  MoreTab.swift
//  RatesView
//
//  Created by Esie on 1/30/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import RWUserInterface
import RWExtensions
import WebKit
import UIKit

enum Settings {
    
    static var settingsParentPage: RWReusableTableViewController {
        let parentVC = RWReusableTableViewController(largeTitle: "Settings")
        parentVC.tableView.backgroundColor = .background
        
        parentVC.addSection(RWSection([
            RWButton(router: "Preferences", to: Settings.settingsPreferencesPage)
        ]))
        
        parentVC.addSection(RWSection([
            RWButton(router: "Data", to: Settings.settingsDataPage),
            RWButton(router: "Notifications", to: Settings.settingsNotificationsPage),
            RWButton(router: "Security", to: Settings.settingsSecurityPage)
        ]))
        
        parentVC.addSection(RWSection([
            RWButton(button: "Contact Developers", icon: UIImage(named: "contact"), completion: {
                let vc = UIViewController()
                let webView = WKWebView()
                vc.view.addSubview(webView)
                webView.frameConstraint()
                let url = URL(string: "https://www.denisesie.com/inappcontact")!
                webView.load(URLRequest(url: url))
                parentVC.present(vc, animated: true)
            })
        ]))
        
        parentVC.addSection(RWSection([
            RWButton(button: "Share App", icon: UIImage(named: "share"), completion: {
                if let app = NSURL(string: "itms-apps://itunes.apple.com/app/id\(AppDelegate.appID)") {
                    let activityVC = UIActivityViewController(activityItems: [app], applicationActivities: nil)
                    parentVC.present(activityVC, animated: true)
                }
            }),
            RWButton(button: "Rate", icon: UIImage(named: "rate"), completion: {
                if let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(AppDelegate.appID)?action=write-review") {
                    if UIApplication.shared.canOpenURL(url as URL) == true  {
                        UIApplication.shared.open(url as URL)
                    }
                }
            })
        ]))
        
//        parentVC.addSection(RWSection([
//            RWButton(predefinedButton: .contactDevelopers),
//            RWButton(predefinedButton: .reportBug)
//        ]))
        
        return parentVC
    }
    
    //MARK: Preferences
    
    static private var settingsPreferencesPage: RWReusableTableViewController {
        let parentVC = RWReusableTableViewController()
        
        parentVC.addSection(RWSection([
            
            RWButton(switch: "Use System Scaling") {
                
            },
            
            RWButton(options: "Scale Options", with:  ["Smaller", "Small", "Normal", "Big", "Bigger"], commands: ["-2","-1", "0", "1", "2"]) {
                let selectedIndex = Int(RWData.get(id: "Scale Options"))!
                ScaleFactor.scaleFactor = ScaleFactor(rawValue: selectedIndex)!
            }
            
        ],header: "View Scaling"))
        
        parentVC.addSection(RWSection([
            
            RWButton(switch: "Use System Animations Settings") {
                
            }/*,
             
             RPButton(options: "Animations Options", with: ["Disable Completely", "Reduce Motion", "Enable"], commands: ["-2","-1", "0"]) {
             
             }*/
            
        ],header: "Animations"))
        
        return parentVC
    }
    
    //MARK: Data
    
    static private var settingsDataPage: RWReusableTableViewController {
        let parentVC = RWReusableTableViewController()
        
        parentVC.addSection(RWSection([
            
            RWButton(switch: "Cache Data For Offline Use") {
                
            },
            
            RWButton(options: "Keep Data For", with:  ["1 Days", "3 Days", "1 Week", "1 Month", "Forever"], commands: ["1","3", "7", "30", "99999"]) {
                let selectedIndex = Int(RWData.get(id: "Scale Options"))!
                ScaleFactor.scaleFactor = ScaleFactor(rawValue: selectedIndex)!
            }
            
        ],header: "DATA CACHE"))
        
        return parentVC
    }
    
    //MARK: Notifications
    
    static private var settingsNotificationsPage: RWReusableTableViewController {
        let parentVC = RWReusableTableViewController()
        
        parentVC.addSection(RWSection([
            
            RWButton(switch: "Cache Data For Offline Use") {
                
            }
            
        ],header: "NOTIFICATIONS"))
        
        return parentVC
    }
    
    //MARK: Security
    
    static private var settingsSecurityPage: RWReusableTableViewController {
        let parentVC = RWReusableTableViewController()
        parentVC.addSection(RWSection([
            
            RWButton(switch: "Use FaceID", completion: {
                
            })
            
            ]))
        return parentVC
    }
    
}
