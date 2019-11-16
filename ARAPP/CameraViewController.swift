//
//  CameraViewController.swift
//  ARAPP
//
//  Created by Zhi Shen Yong on 11/1/19.
//  Copyright © 2019 Zhi Shen Yong. All rights reserved.
//


import UIKit
import SceneKit
import ARKit

class CameraViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: OUTLETS
    // ==============================================================
    
    @IBOutlet weak var sceneView: ARSCNView! // The main AR camera view.
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    // MARK: ACTIONS
    // ==============================================================
    @IBAction func didDeleteButton(_ sender: Any) {
        // Remove the node.
        //  removePointer() automatically fixes the NSPointerArray count.
        guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
        let selectedPosterNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
        posterNodeRefereneces.removePointer(at: selectedPoster)
        selectedPosterNode.removeFromParentNode()
        
        // Take care of deselect nodes.
        selectedPoster = -1
        deleteButton.isHidden = true
        
        for child in sceneView.scene.rootNode.childNodes {
            print(child.childNodes.count)
        }
    }
    @IBAction func didClearButton(_ sender: Any) {

//        // Remove all posterNodes
//        for n in 0 ..< posterNodeRefereneces.count {
//            guard n < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: n) else { return }
//            let posterNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
//            posterNodeRefereneces.removePointer(at: n)
//            posterNode.removeFromParentNode()
//        }
//
//        // Remove all anchorNodes
//        for n in 0 ..< anchorNodeReferences.count {
//            guard n < anchorNodeReferences.count, let pointer = anchorNodeReferences.pointer(at: n) else { return }
//            let anchorNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
//            anchorNodeReferences.removePointer(at: n)
//            anchorNode.removeFromParentNode()
//        }
//
//        let numNodesInRoot = sceneView.scene.rootNode.childNodes.count
//        print("Number of Nodes in rootNode: \(numNodesInRoot)")
    }
    
    
    // MARK: OTHER VARIABLES
    // ==============================================================
    
    var posterNodeRefereneces = NSPointerArray.weakObjects() // Array of added posters.
    var anchorNodeReferences = NSPointerArray.weakObjects()
    var selectedPoster: Int = -1 // Keep track of selected poster.
    
    // MARK: FUNCTIONS
    // ==============================================================
    
    // Called at app load.
    //      1. Configure delete button.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide clear button because it doesn't work rightn ow
        clearButton.isHidden = false
        
        // Configure button.
        deleteButton.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.black.cgColor
        deleteButton.isHidden = true
    }
    
    // Called after the completion of any drawing and animations involved in the
    // initial appearance of the view.
    //      1. Configure the AR camera view.
    //      2. Configure and add various gesture recognizers.
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the AR camera view to detect vertical planes.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Add a tap gesture recognizer to add or deselect posters.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.didTapScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add a long press gesture recognizer to select posters.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.didLongPressScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(longPressGesture)
        
        // Add a pan gesture recognizer to move selected posters around.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.didPanScene(withGestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        // Add a pinch gesture recognizer for resizing selected posters.
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CameraViewController.didPinchScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        // Add a rotate gesture recognizer for rotating selected posters..
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(CameraViewController.didRotateScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(rotateGesture)
    }
    
    // Called when a new anchor corresponding to a plane is detected and added into
    // the scene's rootNode.
    //      1. Create a semi-transparent blue box to roughly show the extent of the
    //          detected plane.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Get the plane anchor.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Declare the extent (size) of the anchor plane.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // Add a material to the plane.
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // Create a plane geometry to accompany the anchor.
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add the plane to the anchor.
        node.addChildNode(planeNode)
        
        // Add the node to the reference array
        let pointer = Unmanaged.passUnretained(node).toOpaque()
        anchorNodeReferences.addPointer(pointer)
    }
    
    // This function is called when a plane anchor has been updated.
    //      1. Here, we need to update the plane node that corresponds
    //          to the plane anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        print(anchorNodeReferences.count)
        
        // Get the plane anchor, as well as its plane node and geometry.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
    
        // Update the extent (size) of the plane node's geometry.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // Calculate the position for the new plane visualizatino.
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        // Update the position of the plane visualization.
        planeNode.position = SCNVector3(x, y, z)
    }
    
    // This function is called when an anchor node is no longer recognized.
    //      1. Delete the plane node that is the child of the anchor node.
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first
            else { return }
        planeNode.removeFromParentNode()
    }
    
    // Rotate a poster after it's been selected.
    // This definitely works.
    @objc func didRotateScene(withGestureRecognizer recognizer: UIRotationGestureRecognizer) {
        if (selectedPoster != -1) {
            if recognizer.state == .began || recognizer.state == .changed {

                // ...
                guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }

                // Get the posterNode that is being referenced.
                let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
                
                // Create a SCNAction to rotate the poster by.
                let action = SCNAction.rotate(by: -recognizer.rotation, around: selectedNode.convertVector(SCNVector3(0, 0, 1), to: selectedNode.parent), duration: TimeInterval(0.1))
                selectedNode.runAction(action)
                
                // Reset the gesture recognizer's rotation property.
                recognizer.rotation = 0
            }
        }
    }
    
    // Resize a poster after it's been selected.
    @objc func didPinchScene(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        if (selectedPoster != -1) {
            if recognizer.state == .began || recognizer.state == .changed {
                
                // ...
                guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
                
                // Get the posterNode that is being referenced.
                let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
                
                // Scale the selected poster.
                selectedNode.scale = SCNVector3(x: Float(recognizer.scale) * selectedNode.scale.x, y: Float(recognizer.scale) * selectedNode.scale.y, z: Float(recognizer.scale) * selectedNode.scale.z)
                
                // Reset the gesture recognizer's scale property.
                recognizer.scale = 1.0
            }
        }
    }
    
    var lastPanLocation: SCNVector3?
    var lastTouchLocation: SCNVector3?
    var didBeginPanOnPoster: Bool = false
    
    @objc func didPanScene(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        
        if (selectedPoster != -1) {
            // Get Referenced Node
            guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
            let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
            
            // Get Location
            let location = recognizer.location(in: sceneView)
            
//            let action = SCNAction.rotate(by: -recognizer.rotation, around: selectedNode.convertVector(SCNVector3(0, 0, 1), to: selectedNode.parent), duration: TimeInterval(0.1))
//            selectedNode.runAction(action)
            
            switch recognizer.state {
            case .began:
                // Check if we begin our panning gesture on a poster.
                let hitList = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
                for hit in hitList.filter( { $0.node.name != nil }) {
                    if hit.node.name == "MyPoster" {
                        if (selectedNode == hit.node) {
                            didBeginPanOnPoster = true
                            lastPanLocation = selectedNode.position
                            
                            let hitForPlane = sceneView.hitTest(location, types: .existingPlane)
                            guard hitForPlane.first != nil else { return }
                            lastTouchLocation = SCNVector3((hitForPlane.first?.worldTransform.columns.3.x)!, (hitForPlane.first?.worldTransform.columns.3.y)!, (hitForPlane.first?.worldTransform.columns.3.z)!)
                        }
                    }
                }
            case .changed:
                if (didBeginPanOnPoster) {
                    let hitTestPlane = sceneView.hitTest(location, types: .existingPlane)
                    guard hitTestPlane.first != nil else { return }
                    
                    let difference = SCNVector3((hitTestPlane.first?.worldTransform.columns.3.x)! - lastTouchLocation!.x, (hitTestPlane.first?.worldTransform.columns.3.y)! - lastTouchLocation!.y, (hitTestPlane.first?.worldTransform.columns.3.z)! - lastTouchLocation!.z)
                    
                    selectedNode.position = SCNVector3(selectedNode.position.x + difference.x, selectedNode.position.y + difference.y, selectedNode.position.z + difference.z)
                    
                    lastTouchLocation = SCNVector3((hitTestPlane.first?.worldTransform.columns.3.x)!, (hitTestPlane.first?.worldTransform.columns.3.y)!, (hitTestPlane.first?.worldTransform.columns.3.z)!)
                }
            default:
                didBeginPanOnPoster = false
                break
            }
        }
    }
    
    // Select a poster by long pressing it.
    @objc func didLongPressScene(withGestureRecognizer recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
                    
            // Get the location of the long press.
            let location = recognizer.location(in: sceneView)
        
            // Get list of objects 'hit' at that location.
            // Assume we haven't found any posters at that location.
            let hitList = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
            print("LONG")
            
            print(hitList.count)
            
            // Iterate through the list of objects 'hit' and check to see if
            // any of them are posters.
            for hit in hitList.filter( { $0.node.name != nil }) {
                if hit.node.name == "MyPoster" {
                    
                    // Iterate through the list of posterNodes that we're
                    // keeping track of. We want to be able to match posters that
                    // are 'hit' to posters we know should exist.
                    for n in 0 ..< posterNodeRefereneces.count {
                        
                        // ...
                        guard n < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: n) else { return }
                        
                        // Get the posterNode that is being referenced.
                        let referencedHit = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
                        
                        // Check if object referenced is *truly* the same object.
                        if (referencedHit === hit.node) {
                            
                            // Haptic feedback!
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                            
                            // Show delete button.
                            deleteButton.isHidden = false
                            
                            // Update material for old object.
                            if (selectedPoster != -1) {
                                guard selectedPoster < posterNodeRefereneces.count, let oldPointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
                                let oldHit = Unmanaged<SCNNode>.fromOpaque(oldPointer).takeUnretainedValue()
                                let unhighlightMat = SCNMaterial()
                                unhighlightMat.diffuse.contents = UIImage(named: "arewecool")
                                unhighlightMat.isDoubleSided = true
                                oldHit.geometry?.materials[0] = unhighlightMat
                            }
                            
                            // Update material for newly selected object.
                            let highlightMat = SCNMaterial()
                            highlightMat.diffuse.contents = UIImage(named: "arewecool")
                            highlightMat.isDoubleSided = true
                            highlightMat.emission.contents = UIColor.yellow.withAlphaComponent(0.1)
                            hit.node.geometry?.materials[0] = highlightMat
                            
                            // Store the index as the selected poster.
                            selectedPoster = n
                        }
                    }
                }
            }
        }
    }
    
    @objc func didTapScene(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            
            // Get location of tap.
            let location = recognizer.location(ofTouch: 0, in: sceneView)
            
            // Get list of objects 'hit' at that location.
            // Assume we haven't found any posters at that location.
            let hitList = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
            print("TAP")
            print(hitList.count)
            print(posterNodeRefereneces.count)
            var foundPoster = false
            
            // Iterate through the list of objects 'hit' and check to see if
            // any of them are posters.
            for hit in hitList.filter( { $0.node.name != nil }) {
                if hit.node.name == "MyPoster" {
                    // If we find a poster, toggle foundPoster.
                    foundPoster = true
                }
            }
            
            // If aren't tapping on a poster...
            if (!foundPoster) {
                
                // If we tap something that's not a poster, deselect any
                // selected posters. Otherwise, create a poster.
                if (selectedPoster != -1) {
                    
                    // Update material for old object.
                    guard selectedPoster < posterNodeRefereneces.count, let oldPointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
                    let oldHit = Unmanaged<SCNNode>.fromOpaque(oldPointer).takeUnretainedValue()
                    let unhighlightMat = SCNMaterial()
                    unhighlightMat.diffuse.contents = UIImage(named: "arewecool")
                    unhighlightMat.isDoubleSided = true
                    oldHit.geometry?.materials[0] = unhighlightMat
                    
                    // Hide delete button.
                    deleteButton.isHidden = true
                    
                    // Unselect posters.
                    selectedPoster = -1
                } else {
                    let hitList = sceneView.hitTest(location,
                    types: .existingPlaneUsingGeometry)
                    
                    if let hit = hitList.first {
                        
                        let posterGeo = SCNPlane(width: 0.05, height: 0.1)
                        let posterMat = SCNMaterial()
                        posterMat.diffuse.contents = UIImage(named: "arewecool")
                        posterMat.isDoubleSided = true
                        posterGeo.materials = [posterMat]
                        
                        let posterNode = SCNNode(geometry: posterGeo)
                        posterNode.transform = SCNMatrix4(hit.anchor!.transform)
                        posterNode.eulerAngles = SCNVector3(posterNode.eulerAngles.x + (-Float.pi / 2), posterNode.eulerAngles.y, posterNode.eulerAngles.z)
                        posterNode.position = SCNVector3(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
                    
                        // Add Poster!
                        posterNode.name = "MyPoster"
                        
                        // BUG: Starting here
                        let pointer = Unmanaged.passUnretained(posterNode).toOpaque()
                        posterNodeRefereneces.addPointer(pointer)
                        sceneView.scene.rootNode.addChildNode(posterNode)
                        
                        
                    } else {
                        print("Not on valid plane!")
                    }
                }
            }
        default:
            print("tapped default")
        }
    }
    
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.5)
    }
}
