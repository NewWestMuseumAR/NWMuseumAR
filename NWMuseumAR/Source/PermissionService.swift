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
        
        debugPrint("Entering \(#function)")
        
        if !CLLocationManager.locationServicesEnabled() {
            self.delegate?.permissionService(didFail: .location)
            return
        }
        
        switch status {
            
        case .authorizedAlways,
             .authorizedWhenInUse:
            self.delegate?.permissionService(didGrant: .location)
            
        case  .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied,
             .restricted:
            self.delegate?.permissionService(didDeny: .location)
        }
        
        debugPrint("Leaving \(#function)")
    }
}
