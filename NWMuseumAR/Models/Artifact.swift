//
//  Artifact.swift
//  NWMuseumAR
//
//  Created by Castiel Li on 2018-02-16.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import Foundation
import UIKit

class Artifact {
    
    var icon: UIImage
    var desc: String
    //basic init function to create an artifact
    init(icon: UIImage,desc: String) {
        self.icon = icon
        self.desc = desc
    }
}
