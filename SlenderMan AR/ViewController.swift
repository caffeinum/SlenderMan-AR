//
//  ViewController.swift
//  SlenderMan AR
//
//  Created by Bartek Lanczyk on 07.09.2018.
//  Copyright © 2018 miltenkot. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            print("Plane is detected")
        } else {
            
            let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            box.materials = [material]
            
            let boxNode = SCNNode(geometry: box)
            
            node.addChildNode(boxNode)
            
        }
        
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touch = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        if !hitTestResults.isEmpty {
            
            let hitTestResult = hitTestResults.first!
            
            let anchor = ARAnchor(name: "box", transform: hitTestResult.worldTransform)
            
            self.sceneView.session.add(anchor: anchor)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
