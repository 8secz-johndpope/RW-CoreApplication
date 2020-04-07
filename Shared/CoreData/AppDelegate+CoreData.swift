//
//  AppDelegate+CoreData.swift
//  RatesView
//
//  Created by Dennis Esie on 12/1/19.
//  Copyright © 2019 Denis Esie. All rights reserved.
//

import Foundation
import CoreData

extension AppDelegate {
    
    static var identifier = "RatesView"
    
    static func saveContext() {
        DispatchQueue.main.async {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error as NSError {
                    print("[CoreData] Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppDelegate.identifier)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error. \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
}
