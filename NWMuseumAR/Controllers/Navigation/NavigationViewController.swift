//
//  NavigationViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-03-22.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation

class NavigationViewController: UIViewController {

    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        let coordinate = CLLocationCoordinate2D(latitude: 51.504571, longitude: -0.019717)
        let location = CLLocation(coordinate: coordinate, altitude: 300)
        let image = UIImage(named: "icon5")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
}
