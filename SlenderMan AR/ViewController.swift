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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private lazy var saveStatusLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var worldMapStatusLabel :UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveListMapButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(red: 53/255, green: 73/255, blue: 94/255, alpha: 1)
        button.addTarget(self, action: #selector(saveListMap), for: .touchUpInside)
        return button
    }()
    
    @objc func saveListMap() {
        
        self.sceneView.session.getCurrentWorldMap { listMap, error in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            if let map = listMap {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                //save in user defaults
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "box")
                userDefaults.synchronize()
                
                self.saveStatusLabel.text = "SAVED"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  self.saveStatusLabel.text = ""
                }
            }
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.autoenablesDefaultLighting = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        self.sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        setupUI()
        
        registerGestureRecognizers()
    }
    
    //MARK: - UI
    
    private func setupUI() {
        
        self.view.addSubview(self.saveStatusLabel)
        self.view.addSubview(self.worldMapStatusLabel)
        self.view.addSubview(self.saveListMapButton)
        
        // add constraints to save status list map label
        self.saveStatusLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.saveStatusLabel.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        self.saveStatusLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        //add constraints to label
        self.worldMapStatusLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.worldMapStatusLabel.rightAnchor.constraint(equalTo: self.sceneView.rightAnchor, constant: -20).isActive = true
        self.worldMapStatusLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // add constraints to save list map button
        self.saveListMapButton.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        self.saveListMapButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -20).isActive = true
        self.saveListMapButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.saveListMapButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            self.worldMapStatusLabel.text = "NOT AVAILABLE"
        case .limited:
            self.worldMapStatusLabel.text = "LIMITED"
        case .extending:
            self.worldMapStatusLabel.text = "EXTENDING"
        case .mapped:
            self.worldMapStatusLabel.text = "MAPPED"
        }
    }
    //workplace
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let plane = anchor as? ARPlaneAnchor,
            let device = renderer.device,
            let geometry = ARSCNPlaneGeometry(device: device)
            else { return nil}
        
        geometry.update(from: plane.geometry)
        
        let maskMaterial = SCNMaterial()
        maskMaterial.colorBufferWriteMask = []
        geometry.materials = [maskMaterial]
        
        let node = SCNNode(geometry: geometry)
        node.renderingOrder = -1
    
        return node
    }
    //workplace
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let plane = anchor as? ARPlaneAnchor,
            let geometry = node.geometry as? ARSCNPlaneGeometry
            else { return }
        geometry.update(from: plane.geometry)
        node.boundingBox = planeBoundary(extent: plane.extent)
        
    }
    //workplace
    private func planeBoundary(extent: float3) -> (min: SCNVector3, max: SCNVector3) {
        
        let radius = extent * 0.5
        return (min: SCNVector3(-radius), max: SCNVector3(radius))
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            print("Plane is detected")
            return
        }
        //add a virtual object list in the future
//        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//
//        box.materials = [material]
//
//        let boxNode = SCNNode(geometry: box)
//
//        node.addChildNode(boxNode)
        
        
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touch = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        if !hitTestResults.isEmpty {
            
            guard let hitResult = hitTestResults.first else {
                return
            }
            
            let boxAnchor = ARAnchor(name: "box", transform: hitResult.worldTransform)
            self.sceneView.session.add(anchor: boxAnchor)
            
        }
    }
    
    private func addSlenderManObject(hitResult: ARHitTestResult) {
        
        let slenderScene = SCNScene(named: "art.scnassets/SlenderMan_Model.scn")
        let slenderNode = slenderScene?.rootNode.childNode(withName: "Slenderman", recursively: true)
        
        slenderNode?.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(slenderNode!)
        
    }
    
    private func addTapeObject(hitResult: ARHitTestResult) {
        
        let tapeScene = SCNScene(named: "art.scnassets/tape/Tape.scn")
        let tapeNode = tapeScene?.rootNode.childNode(withName: "Tape", recursively: true)
        
        tapeNode?.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(tapeNode!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restoreListMap()
    }
    
    private func restoreListMap() {
        
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "box") {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
                let listMap = unarchived {
                let configuration = ARWorldTrackingConfiguration()
                configuration.initialWorldMap = listMap
                configuration.planeDetection = .horizontal
                
                sceneView.session.run(configuration)
            }
        } else {
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.planeDetection = .horizontal
//            sceneView.session.run(configuration)
            startTracking()
        }
        
    }
    //workplace
    private func startTracking() {
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
