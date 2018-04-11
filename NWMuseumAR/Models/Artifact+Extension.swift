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
    
    /**
     Saves a new artifact to the devices local database.
     
     - Parameters:
        - title: The title of the artifact
        - hint: A hint for the artifact
     */
    static func save(withTitle title: String, hint: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let artifact = Artifact(context: context)
        artifact.title = title
        artifact.hint = hint
        artifact.completed = false
        
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
    }
    
    /**
     Updates an artifacts complete status
     
     - Parameters:
        - title: The title of the artifact
     */
    static func setComplete(withTitle title: String, to isComplete: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Artifact")
        let predicate = NSPredicate(format: "title = '\(title)'")
        fetchRequest.predicate = predicate
        
        do {
            let test = try context.fetch(fetchRequest)
            if test.count == 1 {
                
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(isComplete, forKey: "completed")
                
                do {
                    try context.save()
                    debugPrint("Artifact complete: \(isComplete)")
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    /**
     Counts the number of completed Artifacts in the database.
     -  Returns:
     Number of completed artifacts, or -1 if failed
    */
    static func countCompleted() -> Int {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Artifact")
        let predicate = NSPredicate(format: "completed = \(true)")
        fetchRequest.predicate = predicate
        
        var completed = -1
        
        do {
            completed = try context.count(for: fetchRequest)
        } catch {
            print(error)
        }
        return completed
    }
}
