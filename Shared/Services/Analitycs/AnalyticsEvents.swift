//
//  Events.swift
//  RatesView
//
//  Created by Esie on 2/23/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import RWExtensions
import UIKit

enum AnalyticsEvent: String {
    
    case global = "global"
    case watchlist = "watchlist"
    case quicksearch = "quicksearch"
    case chart = "chart"
    case converter = "converter"
    case portfolio = "portfolio"
    case undefined = "undefined"
    
    static var applicationType = "RatesViewCore(undefined)"
    
    //MARK: Events logging
    
    @inline(__always) static func register(source: AnalyticsEvent = .global, key: String, messages: [String] = ["No Messages"], context: String = "No Context...") {
        DispatchQueue.global(qos: .utility).async {
            Analytics.logEvent(source.rawValue + "_" + key, parameters: ["device" : DEVICE_FULL_NAME,
                                                                         "device_identifier" : DEVICE_INDENTIFIER,
                                                                         "ios_version" : UIDevice.current.systemVersion,
                                                                         "core" : applicationType,
                                                                         "user_id" : AnalyticsUserIdentification.userID,
                                                                         "device_id" : AnalyticsUserIdentification.deviceID,
                                                                         "core_version" : Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String,
                                                                         "context" : context,
                                                                         "messages" : messages.joined(separator: ", ")])
        }
    }
}

let RWAnalyticsEventOpened = "opened"
let RWAnalyticsEventClosed = "closed"
let RWAnalyticsEventSearched = "searched"

let RWAnalyticsEventAddedAsset = "asset_added"
let RWAnalyticsEventRemovedAsset = "asset_removed"
let RWAnalyticsEventReorder = "reorder"
let RWAnalyticsEventAddPressed = "add_pressed"
let RWAnalyticsEventAddCanceled = "add_canceled"
let RWAnalyticsEventAddDragged = "add_dragged"
let RWAnalyticsEventAssetOpened = "asset_opened"

let RWAnalyticsEventChartIntervalChanged = "interval_changed"
let RWAnalyticsEventChartStyleChanged = "style_changed"
let RWAnalyticsEventChartIndicatorAdded = "indicator_added"

let RWAnalyticsEventConverted = "converted"
