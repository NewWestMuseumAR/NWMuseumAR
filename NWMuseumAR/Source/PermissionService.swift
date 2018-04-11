//
//  PermissionsService.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-04-09.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

enum PermissionType {
    case location
    case camera
}

protocol PermissionServiceDelegate {
    func permissionService(didGrant permission: PermissionType)
    func permissionService(didDeny permission: PermissionType)
    func permissionService(didFail permission: PermissionType)
}

class PermissionService: NSObject {
    
    private var locationManager: CLLocationManager!
    public var delegate: PermissionServiceDelegate?
    
    private(set) public var locationGranted: Bool = false
    private(set) public var cameraGranted: Bool = false
    
    override init() {
        super.init()
    }
    
    func requestLocationPermission() {
        
        debugPrint("Entering \(#function)")

        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        debugPrint("Leaving \(#function)")
    }
    
    func requestCameraPermission() {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.delegate?.permissionService(didGrant: .camera)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
                
                if granted {
                    self.cameraGranted = true
                    self.delegate?.permissionService(didGrant: .camera)
                } else {
                    self.delegate?.permissionService(didDeny: .camera)
                }
            }
        }
    }
}

extension PermissionService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if !CLLocationManager.locationServicesEnabled() {
            self.delegate?.permissionService(didFail: .location)
            return
        }
        
        switch status {
            
        case .authorizedAlways,
             .authorizedWhenInUse:
            locationGranted = true
            self.delegate?.permissionService(didGrant: .location)
            
        case  .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied,
             .restricted:
            self.delegate?.permissionService(didDeny: .location)
        }
    }
}
