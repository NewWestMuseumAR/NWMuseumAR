//
//  Artifact+Extension.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-04-10.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Artifact {
    
    static func save(withName name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let artifact = Artifact(context: context)
        artifact.title = name
        artifact.image = name.lowercased()
        artifact.completed = false
        
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
    }
    
    static func complete(withName name: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Artifact")
        let predicate = NSPredicate(format: "image = '\(name)'")
        fetchRequest.predicate = predicate
        
        do {
            let test = try context.fetch(fetchRequest)
            if test.count == 1 {
                
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(true, forKey: "completed")
                
                do {
                    try context.save()
                    return true
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print(error)
        }
        return false
    }
}
