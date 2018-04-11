//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import SceneKit
import MapKit
import CocoaLumberjack

@available(iOS 11.0, *)
class NavigationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SceneLocationViewDelegate {
    
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    // Added
    let locationManager = CLLocationManager()
    
    var updateUserLocationTimer: Timer?
    
    var rightArrowImageName: String?
    var rightArrowImage: UIImage?
    var rightArrowImageView: UIImageView?
    var backButtonImageView: UIImageView?
    
    var leftArrowImageName: String?
    var leftArrowImage: UIImage?
    var leftArrowImageView: UIImageView?
    
    var directionToHead: String?
    var showMapView: Bool = true
    
    var centerMapOnUserLocation: Bool = true
    
    var displayDebugging = false
    
    var infoLabel = UILabel()
    
    var updateInfoLabelTimer: Timer?
    
    var adjustNorthByTappingSidesOfScreen = false
    
    private(set) var locationNodes = [LocationNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        sceneLocationView.addSubview(infoLabel)
        sceneLocationView.navigationDelegate = self
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        sceneLocationView.showAxesNode = false
        sceneLocationView.locationDelegate = self
        
        self.rightArrowImageName = "rightArrow.png"
        self.leftArrowImageName = "leftArrow.png"
        
        self.rightArrowImage = UIImage(named: self.rightArrowImageName!)
        leftArrowImageView = UIImageView(image: self.rightArrowImage)
        leftArrowImageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        rightArrowImageView = UIImageView(image: self.rightArrowImage)
        
        leftArrowImageView?.alpha = 0.7
        rightArrowImageView?.alpha = 0.7
        leftArrowImageView?.isHidden = true
        rightArrowImageView?.isHidden = true
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        self.view.addSubview(sceneLocationView)

        rightArrowImageView?.frame = CGRect(x: screenWidth - 100, y: (screenHeight / 2) - 70, width: 70, height: 70)
        leftArrowImageView?.frame = CGRect(x: 10, y: (screenHeight / 2) - 70, width: 70, height: 70)
        
        var myTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        let test = UIView()
        test.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        test.addSubview(rightArrowImageView!)
        test.addSubview(leftArrowImageView!)
        view.addSubview(test)
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            // Added
            mapView.showsUserLocation = true
            mapView.showsPointsOfInterest = true
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            mapView.isHidden = true
            view.addSubview(mapView)
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            } else {
                print("not enabled")
            }
        }
    }
    
    @objc func runTimedCode(sender: UIButton!) {
        let oldCenter = leftArrowImageView?.center
        let newCenter = CGPoint(x: (oldCenter?.x)!-90, y: (oldCenter?.y)!)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.leftArrowImageView?.center = newCenter
        }) { (success: Bool) in
            print("Succeeded in moving")
            UIView.animate(withDuration: 0, delay: 0, options: .curveLinear, animations: {
                self.leftArrowImageView?.center = oldCenter!
            })
        }
        let oldCenterR = rightArrowImageView?.center
        let newCenterR = CGPoint(x: (oldCenterR?.x)!+90, y: (oldCenterR?.y)!)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.rightArrowImageView?.center = newCenterR
        }) { (success: Bool) in
            print("Succeeded in moving")
            UIView.animate(withDuration: 0, delay: 0, options: .curveLinear, animations: {
                self.rightArrowImageView?.center = oldCenterR!
            })
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        locationManager.stopUpdatingLocation()
        
        let sourceCoordinates = location.coordinate
        
        // Location defined to NewWestMinster Museum and Archives, City of NewWestMinster, B.C., Canada
        let destCoordinates = CLLocationCoordinate2DMake(49.2008869,-122.9161565)
        // TODO: Add Final Destination PIN to Museum after project merge
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error getting directions")
            } else {
                let route = response?.routes[0]
                self.mapView.add((route?.polyline)!, level: .aboveRoads)
                
                let rekt = route?.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt!), animated: true)
                
                for route in response!.routes {
                    
                    print(route.steps.count)
                    
                    for step in route.steps {
                        
                        let pointCount = step.polyline.pointCount
                        let array = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: pointCount)
                        
                        step.polyline.getCoordinates(array, range: NSMakeRange(0, pointCount))
                        
                        debugPrint(step.instructions)
                        debugPrint(step.polyline.coordinate)
                        for i in 0..<pointCount {
                            
                            let coord = array[i]
                            
                            if i == pointCount - 1 {
                                self.addAnnotationAndLabelToCoordinate(withCoordinate: coord, text: step.instructions)
                            }
                        }
                        array.deallocate(capacity: pointCount)
                    }
                }
            }
        })
    }
    
    
    func addAnnotationAndLabelToCoordinate(withCoordinate coordinate: CLLocationCoordinate2D, text: String) {
        
        let location = CLLocation(coordinate: coordinate, altitude: 0)
        let image = UIImage(named: "pin")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        annotationNode.setText(text: text)
        
        let geoText = SCNText(string: text, extrusionDepth: 1.0)
        
        geoText.font = UIFont (name: "Arial", size: 8)
        geoText.firstMaterial!.diffuse.contents = UIColor.white
        let textNode = SCNNode(geometry: geoText)
        textNode.scale = SCNVector3(0.5, 0.5, 0.5)
        
        let (minVec, maxVec) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 20)
        
        
        annotationNode.addChildNode(textNode)
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    //Added: Harrison Changes
    func addAnnotationToCoordinate(withCoordinate coordinate: CLLocationCoordinate2D) {
        
        let location = CLLocation(coordinate: coordinate, altitude: 0)
        let image = UIImage(named: "pin")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    
    //Added: This will return the overlay polylines
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer (overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    //Added Camrea will now point in directions of user
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.camera.heading = newHeading.magneticHeading
        mapView.setCamera(mapView.camera, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        if showMapView {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    let translation = bestEstimate.translatedLocation(to: position)
                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
                if self.displayDebugging {
                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Handles our directional arrows as well as updates current location and node location comparison.
     */
    @objc func updateInfoLabel() {
        if let leftRight = sceneLocationView.leftRightLabel {
            switch leftRight {
            case "Left":
                leftArrowImageView?.isHidden = false
                rightArrowImageView?.isHidden = true
            case "Right":
                leftArrowImageView?.isHidden = true
                rightArrowImageView?.isHidden = false
            case "Straight":
                leftArrowImageView?.isHidden = true
                rightArrowImageView?.isHidden = true
            default:
                leftArrowImageView?.isHidden = true
                rightArrowImageView?.isHidden = true
            }
        }
        sceneLocationView.checkLocVsNode()
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

extension NavigationViewController: NavigationViewControllerDelegate {
    
    func userFinishedNavigation() {
        let mainPage = ProgressViewController()
        present(mainPage, animated: true)
    }
}

