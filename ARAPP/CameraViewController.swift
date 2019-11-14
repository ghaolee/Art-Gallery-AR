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

// https://www.appcoda.com/arkit-horizontal-plane/

class CameraViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    // An array to keep track of posters that have been added to the scene.
    var posterNodeRefereneces = NSPointerArray.weakObjects()
    
    // A variable to keep track of which (if any) poster is selected.
    var selectedPoster: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set up the sceneView and gesture recognizers here.
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the scene view.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Add tap gesture to add a poster or to deselect a poster.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.didTapScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add long press gesture to select poster.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.didLongPressScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(longPressGesture)
        
        // Add pan gesture for moving poster around.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.didPanScene(withGestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        // Add pinch gesture for resizing selected poster.
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CameraViewController.didPinchScene(withGestureRecognizer:)))
//        sceneView.addGestureRecognizer(pinchGesture)
        
        // Add rotate gesture for rotating poster.
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(CameraViewController.didRotateScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(rotateGesture)
    }
    
    // Create a transparent plane whenever a new anchor is detected and added to the scene.
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
    }
    
    // Update the anchor planes when possible.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // Get the plane anchor, as well as its node (origin) and geometry.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
        // Update the extent (size) of an existing anchor plane.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // Update the position of an existing anchor plane.
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    // Rotate a poster after it's been selected.
    @objc func didRotateScene(withGestureRecognizer recognizer: UIRotationGestureRecognizer) {
        if (selectedPoster != -1) {
            if recognizer.state == .began || recognizer.state == .changed {

                // ...
                guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }

                // Get the posterNode that is being referenced.
                let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()

                // Rotate the selected poster.
                
                // WHICH IS OF THESE WORK?
                
                // selectedNode.eulerAngles = SCNVector3(selectedNode.eulerAngles.x, selectedNode.eulerAngles.y, selectedNode.eulerAngles.z - Float(recognizer.rotation))
                
                
                
                // TODO Rotate about the parent plane's normal instead.
//                let relativeNormal = selectedNode.parent?.convertVector(SCNVector3(0, 0, 1), to: selectedNode)
//                selectedNode.rotation = SCNVector4(relativeNormal!.x, relativeNormal!.y, relativeNormal!.z, selectedNode.eulerAngles.z - Float(recognizer.rotation))
                
                
     
               //selectedNode.runAction(action)
                // TODO does this work on multiple surfaces?
                //https://stackoverflow.com/questions/45357020/rotate-scnnode-relative-local-coordinates
                let action = SCNAction.rotate(by: .pi, around: selectedNode.convertVector(SCNVector3(0, 0, 1), to: selectedNode.parent), duration: TimeInterval(1))
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
                    
                    selectedNode.position = SCNVector3(selectedNode.position.x + difference.x, selectedNode.position.y + difference.y, selectedNode.position.z)
                    
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
            
            // Iterate through the list of objects 'hit' and check to see if
            // any of them are posters.
            for hit in hitList.filter( { $0.node.name != nil }) {
                if hit.node.name == "MyPoster" {
                    
                    // Haptic feedback!
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    
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
                            // Remove the node. removePointer() automatically fixes the NSPointerArray count.
//                            posterNodeRefereneces.removePointer(at: n)
//                            hit.node.removeFromParentNode()
                            
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
                        
                        let pointer = Unmanaged.passUnretained(posterNode).toOpaque()
                        posterNodeRefereneces.addPointer(pointer)
                        
                        // sceneView?.scene.rootNode.addChildNode(posterNode)
                        
                        if let planeHit = sceneView.hitTest(location, options: nil).first {
                            let planeNode = planeHit.node
                            planeNode.addChildNode(posterNode)
                        }
                        
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
