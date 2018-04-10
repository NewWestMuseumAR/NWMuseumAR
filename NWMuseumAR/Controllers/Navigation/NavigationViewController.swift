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

    var leftArrowImageName: String?
    var leftArrowImage: UIImage?
    var leftArrowImageView: UIImageView?
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = true
    
    var centerMapOnUserLocation: Bool = true
    
    var displayDebugging = false
    
    var infoLabel = UILabel()
    
    var updateInfoLabelTimer: Timer?
    
    var adjustNorthByTappingSidesOfScreen = false
    
    private(set) var locationNodes = [LocationNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        self.rightArrowImageName = "rightArrow.pdf"
        self.leftArrowImageName = "leftArrow.pdf"

        self.rightArrowImage = UIImage(named: self.rightArrowImageName!)
        self.leftArrowImage = UIImage(named: self.leftArrowImageName!)
        
        leftArrowImageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        rightArrowImageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        self.view.addSubview(leftArrowImageView!)
        self.view.addSubview(rightArrowImageView!)

        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
            
        }
        self.view.addSubview(sceneLocationView)
        
    
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            // Added
            mapView.showsUserLocation = true
            mapView.showsPointsOfInterest = true
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        locationManager.stopUpdatingLocation()
        
        let sourceCoordinates = location.coordinate
        //            let destCoordinates = CLLocationCoordinate2DMake(49.2489415, -122.9899965)
        
//        let destCoordinates = CLLocationCoordinate2DMake(49.249212, -123.010059)
        let destCoordinates = CLLocationCoordinate2DMake(49.245648063009874, -122.99804483566106)

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
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        if let leftRight = sceneLocationView.leftRightLabel {
            infoLabel.text!.append("leftRight: \(leftRight) \n")
        }
        
        if let currentLocation = sceneLocationView.locationManager.currentLocation,
            let nextPoint = sceneLocationView.activeLocationNodeQueue.peek()?.location {
            let nextPointDesc = sceneLocationView.activeLocationNodeQueue.peek()?.locationDescription
            infoLabel.text!.append("Distance to next node: " + sceneLocationView.distanceBetweenTwoPoints(a: currentLocation, b: nextPoint).description)
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
        sceneLocationView.checkLocVsNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                } else {
                    
                    let location = touch.location(in: self.view)

                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                        print("left side of the screen")
                        sceneLocationView.moveSceneHeadingAntiClockwise()
                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                        print("right side of the screen")
                        sceneLocationView.moveSceneHeadingClockwise()
                    } else {
                        let image = UIImage(named: "pin")!
                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
                        annotationNode.scaleRelativeToDistance = true
                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                    }
                }
            }
        }
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
        let mainPage = MainPageViewController.init()
        present(mainPage, animated: true)
    }
    
    
}

