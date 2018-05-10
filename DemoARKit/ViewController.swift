//
//  ViewController.swift
//  DemoARKit
//
//  Created by Trabelsi Achraf on 5/10/18.
//  Copyright © 2018 TADEV. All rights reserved.
//

import UIKit
import ARKit

// Transforms a matrix into float3. It returns the x, y, and z from the matrix.
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add3DObjects()
        addTapGestureToSceneView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop AR session tracking
        sceneView.session.pause()
    }
    
    /// Configure the ARKit SceneKit View : this is a configuration for running world tracking
    func configureScene() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    // Add 3D objects to ARSCNView : boxes with a SCNMaterial that contains image
    func add3DObjects(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        // Get a random image from the list every time we tap on the screen
        let imagesNames = ["bilbil", "sadma", "lacha"]
        let randomIndex = Int(arc4random_uniform(UInt32(imagesNames.count)))
        
        // Add a SCNMaterial that contains an image from the list
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: imagesNames[randomIndex])
        material.locksAmbientWithDiffuse = true
        box.materials = [material]
        
        // Create a node that represents the position of an object in the 3D space
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(boxNode)
    }

    /// Add a tap gesture to add and remove 3D objects from the scene
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                add3DObjects(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        node.removeFromParentNode()
    }
}

