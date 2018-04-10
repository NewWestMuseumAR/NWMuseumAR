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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        artifacts = createArtifacts()
        
        //assigned tableview to the controller
        //in order to use the extension methods
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    //creates an array of artifacts as dummy data for testing
    //This will be replaced by database of some sort later on
    func createArtifacts() -> [Artifact]
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artifact")
        
        do {
            artifacts = try context.fetch(fetchRequest) as! [Artifact]
            debugPrint(artifacts)
            self.tableView.reloadData()
        }catch let err as NSError {
            print(err.debugDescription)
        }
        return artifacts
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
