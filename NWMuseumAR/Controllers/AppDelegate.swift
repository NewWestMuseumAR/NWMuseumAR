//
//  AppDelegate.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-01-31.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import CoreData
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NWMuseumAR")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Should be replaced with code to fail gracefully
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let homeViewController: UIViewController
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        // iOS 11.3 required, ARWorldTracking capable chip required
        if ARWorldTrackingConfiguration.isSupported, #available(iOS 11.3, *){
            
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            // Show tutorial, add launchedbefore to storage

            if launchedBefore  {
                // Skip Tutorial
                homeViewController = ProgressViewController()
            } else {
                // Show tutorial, add launchedbefore to storage
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                homeViewController = OnboardingController(collectionViewLayout: layout)
                // TODO: - Remove this shit
                //UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
            
            // seed database if not already seeded
            let seeded = UserDefaults.standard.bool(forKey: "seeded")
            debugPrint("Seeded? \(seeded)")
            if !seeded {
                seedDatabase()
                UserDefaults.standard.set(true, forKey: "seeded")
            }
            
        } else {
            homeViewController = DeviceNotSupportedViewController(collectionViewLayout: layout)
        }
        
        // Show our starting controller to the user
        window!.rootViewController = homeViewController
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func seedDatabase() {
        
        debugPrint("Seeding database")
        
        for artifact in SEED_DATA {
            debugPrint(artifact)
            Artifact.save(withTitle: artifact["title"]!, hint: artifact["hint"]!, image: artifact["image"]!)
        }
        
        debugPrint("database seeded")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
