//
//  ARSceneViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-03-29.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import ARKit

class ARSceneViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Basic Debugging Options
    let IS_DEBUG: Bool = false
    var IS_VIDEO: Bool = false
    
    // MARK: - UI Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    // The artifact passed from the progress view controller
    var artifactSelected: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var detectedArtifact: String? = nil
    var isRestartAvailable = true
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.flatMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARDelegate()
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
}

// MARK: - Touch Handling
extension ARSceneViewController {
    
    /// - Tag: Touch event detected
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Touch event detected!")
        
        //get first touch
        let touch = touches.first!
        
        //get location of touch in scene
        let location = touch.location(in: sceneView)
        
        //get hit results
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            handleTouch()
        }
    }
    
    /// - Tag: Handling the touch event
    func handleTouch() {
        if detectedArtifact == nil { return }
        
        let node = sceneView.scene.rootNode.childNode(withName: "artifact", recursively: true)
        
        if (node != nil) {
            createExplosion(node: node!, geometry: node!.geometry!, position: node!.presentation.position,
                            rotation: node!.presentation.rotation)
        }
    }
}

// MARK: - Animations
extension ARSceneViewController {
    
    /// - Tag: Explosion - triggered on touching of node!
    func createExplosion(node: SCNNode, geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        
        node.addParticleSystem(explosion)
    }
    
    /// - Tag: Fades opacity of Node and removes it from it's parent node
    func fadeAndRemoveNode(node: SCNNode, time: Double) {
        
        let fadeRemove = SCNAction.sequence([
            .fadeOut(duration: time),
            .removeFromParentNode()
            ])
        
        node.runAction(fadeRemove)
    }
    
    /// - Tag: Moves node up and down continuously. NOTE: Depends on orientation of node...
    func oscillateNode(node: SCNNode) {
        let moveUp = SCNAction.moveBy(x: 0, y: 0, z: 0.05, duration: 1)
        moveUp.timingMode = .easeInEaseOut;
        
        let moveDown = SCNAction.moveBy(x: 0, y: 0, z: -0.05, duration: 1)
        moveDown.timingMode = .easeInEaseOut;
        
        let moveSequence = SCNAction.sequence([moveUp,moveDown])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        
        node.runAction(moveLoop)
    }
    
    /// - Tag: Spins node continuously. NOTE: Depends on orientation of node...
    func spinNode(node: SCNNode) {
        let spinLoop = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 0, 1), duration: 5))
        
        node.runAction(spinLoop)
    }
    
    func oscillateAndSpinNode(node: SCNNode) {
        oscillateNode(node: node)
        spinNode(node: node)
    }
}


// MARK: - ARSessionDelegate
extension ARSceneViewController: ARSessionDelegate {
    
    /// - Tag: Setup the AR delegate when loading view
    func setupARDelegate() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        if IS_DEBUG {
            sceneView.debugOptions =  [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        statusViewController.showMessage("RESETTING SESSION")
        
        restartExperience()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1
            planeNode.name = "artifact"
            
            if self.IS_VIDEO { // TODO: For debugging - property is at top of class
                
                let videoNode = SKVideoNode(fileNamed: "test1.mp4")
                videoNode.play()
                
                let skScene = SKScene(size: CGSize(width: 640, height: 480))
                skScene.addChild(videoNode)
                
                videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
                videoNode.size = skScene.size
                
                plane.firstMaterial?.diffuse.contents = skScene
                plane.firstMaterial?.isDoubleSided = true
                
                planeNode.eulerAngles.x = -.pi / 2
                
                node.addChildNode(planeNode)
                
            } else { // This is if we want coin
                
                let coin = SCNScene(named: "coin.dae", inDirectory: "art.scnassets")!
                coin.rootNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
                
                let moveUp = SCNAction.moveBy(x: 0, y: 0, z: 0.05, duration: 1)
                moveUp.timingMode = .easeInEaseOut;
                
                let moveDown = SCNAction.moveBy(x: 0, y: 0, z: -0.05, duration: 1)
                moveDown.timingMode = .easeInEaseOut;
                
                let moveSequence = SCNAction.sequence([moveUp,moveDown])
                let moveLoop = SCNAction.repeatForever(moveSequence)
                
                let spinLoop = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 0, 1), duration: 5))
                
                coin.rootNode.runAction(moveLoop)
                coin.rootNode.runAction(spinLoop)
                
                node.addChildNode(coin.rootNode)
            }
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
            self.detectedArtifact = imageName
        }
    }
    
    // MARK: - Interface Actions
    /// - Tag: Restart the entire AR session along with tracking
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        statusViewController.cancelAllScheduledMessages()
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        debugPrint("Entering \(#function)")
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.planeDetection = .vertical
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
        
        debugPrint("Leaving \(#function)")
    }
    
    // MARK: - Error handling
    /// - Tag: Displaying error messages
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}
