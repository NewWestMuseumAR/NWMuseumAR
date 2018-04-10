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
    
    static func complete(withTitle title: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Artifact")
        let predicate = NSPredicate(format: "title = '\(title)'")
        fetchRequest.predicate = predicate
        
        do {
            let test = try context.fetch(fetchRequest)
            if test.count == 1 {
                
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(true, forKey: "completed")
                
                do {
                    try context.save()
                    debugPrint("Artifact completion saved")
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print(error)
        }
    }
}
