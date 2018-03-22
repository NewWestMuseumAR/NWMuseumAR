//
//  ProgressViewController.swift
//  NWMuseumAR
//
//  Created by Castiel Li on 2018-03-04.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ProgressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ArtifactName: UILabel!
    
    @IBOutlet weak var ArtifactDesc: UILabel!
    @IBOutlet weak var ArtifactIcon: UIImageView!
}

class ProgressViewController : UITableViewController {
    //context used to access database
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //temp array of artifact that will fetch from database when app started
    var artifactArray = [Artifact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createArtifacts()
        loadArtifacts()
        setupNavBar()
        updateTableViewStyle()
    }
    //try to display the Navbar but failed so far
    func setupNavBar() {
        navigationController?.navigationBar.isHidden = false;
        navigationController?.navigationBar.prefersLargeTitles = true;
        navigationController?.navigationBar.tintColor = UIColor.black;
    }
    
    //MARK - Tableview Datasource Methods
    
    //display the number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifactArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtifactCell", for: indexPath) as! ProgressTableViewCell
        let artifact = artifactArray[indexPath.row]
        cell.ArtifactIcon.image = UIImage(named: artifact.icon!)
        cell.ArtifactName.text = artifact.name
        cell.ArtifactDesc.text = artifact.desc
        updateCellStyle(cell: cell)
        return cell
    }
    
    //MARK - TableView Delegate Methods
    //prep for the seque to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MasterToDetail" {
            let destVC = segue.destination as! DetailViewController
            destVC.artifact = sender as? Artifact
        }
    }
    
    //when a item click, sent to detail page with a Artifact object
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artifact = artifactArray[indexPath.row]
        performSegue(withIdentifier: "MasterToDetail", sender: artifact)    }
    
    //MARK - TableData Prep Methods
    
    //create a list of sample data
    func createArtifacts()
    {
        createNewArtifact(icon: "icon1", name: "Icon1", image: "Icon1Image", desc: "Pick up that skull")
        createNewArtifact(icon: "icon2", name: "Icon2", image: "Icon2Image", desc: "Lighting in that box")
        createNewArtifact(icon: "icon3", name: "Icon3", image: "Icon3Image", desc: "Need a flower")
        createNewArtifact(icon: "icon4", name: "Icon4", image: "Icon4Image", desc: "Protect Binary")
        createNewArtifact(icon: "icon5", name: "Icon5", image: "Icon5Image", desc: "No idea whats this")
        createNewArtifact(icon: "icon6", name: "Icon6", image: "Icon6Image", desc: "Grow up")
    }
    
    //create a single artifact and save to database
    func createNewArtifact(icon : String, name : String, image: String, desc : String)
    {
        let newArtifact = Artifact(context: self.context)
        newArtifact.name = name
        newArtifact.icon = icon
        newArtifact.image = image
        newArtifact.desc = desc
        self.artifactArray.append(newArtifact)
        self.saveArtifacts()
    }
    
    //MARK - Model Manupulation Methods CRUD
    
    //Save data
    func saveArtifacts() {
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    //Read data
    func loadArtifacts() {
        let request : NSFetchRequest<Artifact> = Artifact.fetchRequest()
        do {
            artifactArray = try context.fetch(request)
        } catch {
            print("Error feching data from context \(error)")
        }
    }
    
    //MARK - Style Manupulation Methods
    func updateCellStyle(cell : ProgressTableViewCell ) {
        
        cell.ArtifactIcon.layer.cornerRadius = 50
        cell.ArtifactIcon.layer.borderColor = UIColor.blue.cgColor
        cell.ArtifactIcon.layer.borderWidth = 3
        cell.ArtifactIcon.layer.backgroundColor = UIColor.blue.cgColor
        cell.ArtifactIcon.layer.opacity = 0.5
    }
    
    func updateTableViewStyle() {
        self.tableView.separatorStyle = .none
    }
}
