//
//  ViewController.swift
//  NWMuseumAR
//
//  Created by Harrison Milbradt on 2018-01-31.
//  Copyright © 2018 NWMuseumAR. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ARViewCOntroller: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var textOverlay: UITextField!
    
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    var visionRequests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // --- ARKIT ---
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // --- ML ---
        guard let selectedModel = try? VNCoreMLModel(for: handmodel().model) else {
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project. Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
        }
        
        // set up vision-coreml request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
        //begin loop to update coreml
        loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // --- ARSCNViewDelegate ---
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    // --- MACHINE LEARNING ---
    
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            // 2. Loop this function.
            self.loopCoreMLUpdate()
        }
    }
    
    func updateCoreML() {
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Run Vision Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...1] // top 3 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        // Render Classifications
        DispatchQueue.main.async {
            // Print Classifications
            // print(classifications)
            // print("-------------")
            
            // Display Debug Text on screen
//            self.debugTextView.text = "TOP 3 PROBABILITIES: \n" + classifications
            
            // Display Top Symbol
            var symbol = "🚫"
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // Only display a prediction if confidence is above 1%
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                if (topPredictionName == "open hand") { symbol = "✋🏻" }
                if (topPredictionName == "closed hand") { symbol = "✊🏻" }
                if (topPredictionName == "not hand") { symbol = "🚫" }
            }
            
            self.textOverlay.text = symbol
            
        }
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
