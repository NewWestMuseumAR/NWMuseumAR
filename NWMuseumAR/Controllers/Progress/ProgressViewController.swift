//
//  ProgressViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-02-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import CoreData

class ProgressViewController: UIViewController {

    // MARK: - TableView data creation
    @IBOutlet weak var tableView: UITableView!
    
    var artifacts: [Artifact] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        

        
        getArtifacts()
        
        //assigned tableview to the controller
        //in order to use the extension methods
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    //creates an array of artifacts as dummy data for testing
    //This will be replaced by database of some sort later on
    func getArtifacts()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artifact")
        
        do {
            artifacts = try context.fetch(fetchRequest) as! [Artifact]
            debugPrint(artifacts)
            self.tableView.reloadData()
        }catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func completeArtifact(withName name: String) {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Artifact")
        let predicate = NSPredicate(format: "imageName = '\(name)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try context.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(true, forKey: "completed")
                do {
                    try context.save()
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
}

//find the cell and display info as needed
extension ProgressViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource, UITableViewDelegate
    //this function sets how mant rolls are we displaying
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //display all the artifacts in the array
        return artifacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //select an artifact based on the row number
        let artifact = artifacts[indexPath.row]
        //create an instance of the cell on that roll
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtifactCell") as! ProgressCell
        //call setArtifact function in ProgressCell.swift
        cell.setArtifact(artifact: artifact)
        //return the cell after update with icon and description
        return cell
    }
}
