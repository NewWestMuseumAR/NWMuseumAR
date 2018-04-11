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
    
    // MARK: - UI Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    var targetArtifactName: String?
    var userDetectedArtifact: Bool = false
    
    var overlayMode = false
    var overlayView: OverlayView!
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sceneTapped))
        sceneView.addGestureRecognizer(tap)
        
        setupARDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.view.addSubview(navigationBar)
        
        // Start the AR experience
        resetTracking()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        navigationExitButton.addTarget(self, action: #selector(performSeque), for: .touchUpInside)
        navigationBar.addSubview(navigationExitButton)
        
        NSLayoutConstraint.activate([
            // Scene View
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            // Navigation Bar Container
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 60),
            
            // Nav Exit Button
            navigationExitButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -14),
            navigationExitButton.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 14),
            navigationExitButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -14),
            navigationExitButton.widthAnchor.constraint(equalToConstant: 60)
            ])
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    @IBAction func exitButton(_ sender: UIButton) {
        performSeque()
    }
    
    /** Navigation Bar Overlay */
    let navigationBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.17, alpha: 1.0)
        return view
    }()
    
    /** Navigation Exit Button */
    let navigationExitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.setImage(#imageLiteral(resourceName: "Exit Icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    @objc func performSeque() {
        
        let progressViewController = ProgressViewController()
        
        show(progressViewController, sender: self)
    }
    
    func showOverlay() {
        self.overlayBlurredBackgroundView()
        overlayMode = true
        
        instantiateOverlayContainer()
        
        // Set detected artifact back to nil to disable click
        userDetectedArtifact = false
    }
    
    @objc func continueButtonClicked(_ : UIButton) {
        performSeque()
    }
    
    func instantiateOverlayContainer() {
        overlayView = OverlayView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        overlayView.artifact = targetArtifactName!
        overlayView.image = UIImage.init(named: "" + targetArtifactName! + "Icon")
        overlayView.parentController = self
        view.addSubview(overlayView)
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
    }
}

// MARK: - Touch Handling
extension ARSceneViewController {
    
    @objc func sceneTapped(recognizer :UITapGestureRecognizer) {
        if userDetectedArtifact == false { return }
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitResults.isEmpty {
            
            guard let hitResult = hitResults.first else { return }
            
            let coinNode = hitResult.node
            
            createExplosion(node: coinNode, position: coinNode.presentation.position,
                            rotation: coinNode.presentation.rotation)
            fadeAndRemoveNode(node: coinNode, time: 0.5)
            
            userDetectedArtifact = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                
                Artifact.setComplete(withTitle: self.targetArtifactName!, to: true)
                self.showOverlay()
            }
        }
    }
}

// MARK: - Animations
extension ARSceneViewController {
    
    /// - Tag: Explosion - triggered on touching of node!
    func createExplosion(node: SCNNode, position: SCNVector3,
                         rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!
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
    
    /// - Tag: Adds video to node
    func addVideo(node: SCNNode, plane: SCNPlane, video: String?) {
        let planeNode = SCNNode(geometry: plane)
        planeNode.name = "artifact"
        planeNode.opacity = 1
        
        let videoNode = SKVideoNode(fileNamed: video! + ".mp4")
        videoNode.play()
        
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        plane.firstMaterial?.diffuse.contents = skScene
        plane.firstMaterial?.isDoubleSided = true
        
        planeNode.eulerAngles.x = .pi / 2
        
        node.addChildNode(planeNode)
    }
}


// MARK: - ARSessionDelegate
extension ARSceneViewController: ARSessionDelegate {
    
    /// - Tag: Setup the AR delegate when loading view
    func setupARDelegate() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            debugPrint("Tracking is limited")
        case .normal:
            debugPrint("Tracking is normal")
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        // TODO: - Comment out for production
        if referenceImage.name == "Github Logo" {
            referenceImage.name = "Fire"
        }
        
        if referenceImage.name != targetArtifactName {
            debugPrint("\(referenceImage.name!) is not a match for \(targetArtifactName!). Exiting.")
            return
        }
        
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            //            let plane = SCNPlane(width: referenceImage.physicalSize.width,
            //                                 height: referenceImage.physicalSize.height)
            
            //            if self.targetArtifactName == "notebook" || self.targetArtifactName == "Fire" {
            //                self.addVideo(node: node, plane: plane, video: self.targetArtifactName!)
            //            }
            
            let coin = SCNScene(named: "coin.dae", inDirectory: "art.scnassets")!
            let coinNode = coin.rootNode
            
            coinNode.name = "coin"
            coinNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            
            self.oscillateAndSpinNode(node: coinNode)
            
            node.addChildNode(coinNode)
        }
        
        DispatchQueue.main.async {
            self.userDetectedArtifact = true
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
        
        debugPrint("Leaving \(#function)")
    }
    
    /** Hide Status Bar */
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
