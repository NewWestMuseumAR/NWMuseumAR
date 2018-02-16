//
//  ProgressViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-02-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

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
        var tempArtifacts: [Artifact] = []
        
        let Artifact1 = Artifact(icon: #imageLiteral(resourceName: "icon1"), desc: "Pick up that skull")
        let Artifact2 = Artifact(icon: #imageLiteral(resourceName: "icon2"), desc: "Lighting in that box")
        let Artifact3 = Artifact(icon: #imageLiteral(resourceName: "icon3"), desc: "Need a flower")
        let Artifact4 = Artifact(icon: #imageLiteral(resourceName: "icon4"), desc: "Protect Binary")
        let Artifact5 = Artifact(icon: #imageLiteral(resourceName: "icon5"), desc: "No idea whats this")
        let Artifact6 = Artifact(icon: #imageLiteral(resourceName: "icon6"), desc: "Grow up")
        
        tempArtifacts.append(Artifact1)
        tempArtifacts.append(Artifact2)
        tempArtifacts.append(Artifact3)
        tempArtifacts.append(Artifact4)
        tempArtifacts.append(Artifact5)
        tempArtifacts.append(Artifact6)
        
        return tempArtifacts
    }
}

//find the cell and display info as needed
extension ProgressViewController: UITableViewDataSource, UITableViewDelegate {
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
