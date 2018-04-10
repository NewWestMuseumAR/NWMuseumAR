//
//  ProgressCell.swift
//  NWMuseumAR
//
//  Created by Castiel Li on 2018-02-16.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    @IBOutlet weak var artifactIcon: UIImageView!
    var name: String?
    @IBOutlet weak var artifactDescription: UILabel!
    //Set the image view and label to display artifact information
    func setArtifact(artifact: Artifact) {
        debugPrint(artifact.image)
        artifactIcon.image = UIImage(named: artifact.image!)
        name = artifact.title!
        artifactDescription.text = "Completed: \(artifact.completed)"
    }
}

