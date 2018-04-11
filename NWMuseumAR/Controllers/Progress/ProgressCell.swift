//
//  ProgressCell.swift
//  NWMuseumAR
//
//  Created by Castiel Li on 2018-02-16.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    
    // required to pass back messages
    weak var parentViewController: ProgressViewController?
    
    @IBOutlet weak var artifactIcon: UIImageView!
    var title: String?
    @IBOutlet weak var artifactDescription: UILabel!
    
    //Set the image view and label to display artifact information
    func setArtifact(artifact: Artifact) {
        artifactIcon.image = UIImage(named: artifact.title!)
        title = artifact.title!
        artifactDescription.text = "Completed: \(artifact.completed)"
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.parentViewController?.performSegue(withArtifactTitle: self.title!)
    }
}

