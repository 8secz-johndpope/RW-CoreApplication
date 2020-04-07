//
//  AppDelegate+InitialSettings.swift
//  RatesView
//
//  Created by Dennis Esie on 12/1/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    private static let versionOfLastRunKey = "VersionOfLastRun"
    private static var lauchedBeforKey: String { "lauched-before-for-\(internalVersionIteration)" }
    
    static var internalVersionIteration = 2.99
    static var installState: ApplicationInstallState?
    
    static func setInitialSettings() {
        checkForAppUpdate()
        if !UserDefaults.standard.bool(forKey: lauchedBeforKey) {
            UserDefaults.standard.set(true, forKey: lauchedBeforKey)
            setInitial()
        }
    }
    
    static private func checkForAppUpdate() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: versionOfLastRunKey) as? String

        if versionOfLastRun == nil {
            installState = .firstRun
        } else if versionOfLastRun != currentVersion {
            installState = .updated
        } else {
            installState = .nothingChanged
        }
        
        if versionOfLastRun == "2.6" {
            installState = .legacyTransitionNeededFromDefaults
        } else if versionOfLastRun == "2.95" {
            installState = .legacyTransitionNeededFromCoreData
        }

        UserDefaults.standard.set(currentVersion, forKey: versionOfLastRunKey)
    }
    
    enum ApplicationInstallState: String {
        case firstRun = "First start after installing the app."
        case updated = "App was updated since last run."
        case legacyTransitionNeededFromDefaults = "Transition from defaults needed."
        case legacyTransitionNeededFromCoreData = "Transition from legacy core data needed."
        case nothingChanged = "App version not changed."
    }
    
    static private func setInitial() {
//        RTVCData.set(string: "30 Minutes", id: "Update frequency")
//        RTVCData.set(string: "1H", id: "Chart interval")
//        RTVCData.set(bool: true, id: "Use offline data")
//        RTVCData.set(string: "4 Hours", id: "Widget update frequency")
//        RTVCData.set(bool: true, id: "Update over cellular data")
//        RTVCData.set(bool: true, id: "Auto")
//        RTVCData.set(bool: true, id: "In-App sounds")
//        RTVCData.set(string: "Every week", id: "Push news")
//        RTVCData.set(string: "Off", id: "Push rates")
//        RTVCData.set(string: "-", id: "Rates to push")
//        RTVCData.set(bool: true, id: "Use iCloud sync")
//        RTVCData.set(string: "Default", id: "Scale")
        
//        if let regionCode = Locale.current.regionCode {
//            let locale = AppModel.getCountryName(name: regionCode)
//            RTVCData.set(string: locale, id: "Select country")
//        }
    }
    
    
    
}
