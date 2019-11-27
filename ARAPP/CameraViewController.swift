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
    @IBOutlet weak var makeVertical: UIButton!
    @IBOutlet weak var findingPlaneLabel: UILabel!
    @IBOutlet weak var findingPlaneIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numPlanesButton: UIButton!
    @IBOutlet weak var invalidPlaneLabel: UILabel!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var resetSize: UIButton!
    
    

    
    // MARK: ACTIONS
    // ==============================================================
    @IBAction func didDeleteButton(_ sender: Any) {
        // Remove the node.
        //  removePointer() automatically fixes the NSPointerArray count.
        guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
        let selectedPosterNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
        posterNodeRefereneces.removePointer(at: selectedPoster)
        posterImageNameArray.remove(at: selectedPoster)
        selectedPosterNode.removeFromParentNode()
        posterAnglesArray.remove(at: selectedPoster)
        
        // Take care of deselect nodes.
        selectedPoster = -1
        deleteButton.isHidden = true
        makeVertical.isHidden = true
        resetSize.isHidden = true
        widthLabel.isHidden = true
        lengthLabel.isHidden = true
        
    }
    
    @IBAction func resetSize(_ sender: Any) {
        guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else {return}
        let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
        selectedNode.scale = SCNVector3Make(1,1,1)
        
   
        
        let nodeWidth = (selectedNode.boundingBox.max.x - selectedNode.boundingBox.min.x) * 100 * selectedNode.scale.x
        let nodeWidthRounded = String(format: "%.1f", nodeWidth)
        let nodeLength = (selectedNode.boundingBox.max.y - selectedNode.boundingBox.min.y) * 100 * selectedNode.scale.y
        let lengthWidthRounded = String(format: "%.1f", nodeLength)
        widthLabel.text = "Width: \(nodeWidthRounded)"
        lengthLabel.text = "Length: \(lengthWidthRounded)"
        
    }
    @IBAction func makeVertical(_ sender: Any) {
        // commit testing
        guard selectedPoster < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: selectedPoster) else {return}
        let selectedNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
        selectedNode.eulerAngles = posterAnglesArray[selectedPoster]
        
    }
    @IBAction func numPlanesAction(_ sender: Any) {
        
        for n in 0 ..< planeNodeReferences.count {
            guard n < planeNodeReferences.count, let pointer = planeNodeReferences.pointer(at: n) else { return }
            let planeNode = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
            
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.7)
            let duration: TimeInterval = 3
            
            let action = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
                
                var percentage = CGFloat(0)
                if elapsedTime > 1.00 {
                    percentage = (elapsedTime - 1) / CGFloat(duration)
                }
                
                node.geometry?.firstMaterial?.diffuse.contents = self.animateColor(percentage: CGFloat(percentage))
            })
            planeNode.runAction(action)
        }
    
    }
    
    func animateColor(percentage: CGFloat) -> UIColor {
        let color = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.7 + (0.0 - 0.7) * percentage)
        return color
    }
    
    
    // MARK: OTHER VARIABLES
    // ==============================================================
    
    var posterNodeRefereneces = NSPointerArray.weakObjects() // Array of added posters.
    var posterImageNameArray: [String] = []
    var posterAnglesArray: [SCNVector3] = []
    var planeNodeReferences = NSPointerArray.weakObjects()
    var selectedPoster: Int = -1 // Keep track of selected poster.
    var hasDetectedPlane: Bool = false //
    var numPlanesDetected: Int = 0
    var showingInvalid: Bool = false
    
    // MARK: FUNCTIONS
    // ==============================================================
    
    // Called at app load.
    //      1. Configure delete button.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Finding Plane
        findingPlaneIndicator.hidesWhenStopped = true
        findingPlaneIndicator.startAnimating()
        
        findingPlaneLabel.text = "Looking for Plane..."
        findingPlaneLabel.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        findingPlaneLabel.layer.cornerRadius = 5
        findingPlaneLabel.layer.borderWidth = 1
        findingPlaneLabel.layer.borderColor = UIColor.black.cgColor
        
        // Width n Length text
        widthLabel.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        widthLabel.layer.cornerRadius = 5
        widthLabel.layer.borderWidth = 1
        widthLabel.layer.borderColor = UIColor.black.cgColor
        widthLabel.isHidden = true
        
        lengthLabel.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        lengthLabel.layer.cornerRadius = 5
        lengthLabel.layer.borderWidth = 1
        lengthLabel.layer.borderColor = UIColor.black.cgColor
        lengthLabel.isHidden = true
        
        // Configure button.
        makeVertical.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        makeVertical.layer.cornerRadius = 5
        makeVertical.layer.borderWidth = 1
        makeVertical.layer.borderColor = UIColor.black.cgColor
        makeVertical.isHidden = true
        
        resetSize.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        resetSize.layer.cornerRadius = 5
        resetSize.layer.borderWidth = 1
        resetSize.layer.borderColor = UIColor.black.cgColor
        resetSize.isHidden = true
        
        deleteButton.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.black.cgColor
        deleteButton.isHidden = true
        
        invalidPlaneLabel.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        invalidPlaneLabel.layer.cornerRadius = 5
        invalidPlaneLabel.layer.borderWidth = 1
        invalidPlaneLabel.layer.borderColor = UIColor.black.cgColor
        invalidPlaneLabel.isHidden = true
        
        numPlanesButton.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        numPlanesButton.layer.cornerRadius = 5
        numPlanesButton.layer.borderWidth = 1
        numPlanesButton.layer.borderColor = UIColor.black.cgColor
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
        sceneView.session.delegate = self
        sceneView.delegate = self
        
        // Start Detecting Plane Animation

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
        
        // Disable the Looking for Plane Animation
        hasDetectedPlane = true
        DispatchQueue.main.async {
            self.numPlanesDetected = self.numPlanesDetected + 1
            self.numPlanesButton.setTitle("Planes: \(self.numPlanesDetected)", for: .normal)
            self.findingPlaneIndicator.stopAnimating()
            self.findingPlaneIndicator.isHidden = true
            self.findingPlaneLabel.isHidden = false
            self.findingPlaneLabel.alpha = 1.0
            self.findingPlaneLabel.text = "Plane Found!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                self.findingPlaneLabel.alpha = 0.0
            }, completion: { (isCompleted) in
                self.findingPlaneLabel.isHidden = true
            })
        }
        
        // Declare the extent (size) of the anchor plane.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // Add a material to the plane.
        plane.materials.first?.diffuse.contents = UIColor.planeColor
        
        // Create a plane geometry to accompany the anchor.
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Animate plane geo
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.7)
        let duration: TimeInterval = 3
        let action = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            
            var percentage = CGFloat(0)
            if elapsedTime > 1.00 {
                percentage = (elapsedTime - 1) / CGFloat(duration)
            }
            
            node.geometry?.firstMaterial?.diffuse.contents = self.animateColor(percentage: CGFloat(percentage))
        })
        planeNode.runAction(action)
        
        // Add the plane to the anchor.
        node.addChildNode(planeNode)
        
        // Add the node to the reference array
        let pointer = Unmanaged.passUnretained(planeNode).toOpaque()
        planeNodeReferences.addPointer(pointer)
    }
    
    // This function is called when a plane anchor has been updated.
    //      1. Here, we need to update the plane node that corresponds
    //          to the plane anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
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
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.numPlanesDetected = self.numPlanesDetected - 1
            self.numPlanesButton.setTitle("Planes: \(self.numPlanesDetected)", for: .normal)
        }
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
                
                // Update width and length text
                let nodeWidth = (selectedNode.boundingBox.max.x - selectedNode.boundingBox.min.x) * 100 * selectedNode.scale.x
                let nodeWidthRounded = String(format: "%.1f", nodeWidth)
                let nodeLength = (selectedNode.boundingBox.max.y - selectedNode.boundingBox.min.y) * 100 * selectedNode.scale.y
                let lengthWidthRounded = String(format: "%.1f", nodeLength)
                widthLabel.text = "Width: \(nodeWidthRounded)"
                lengthLabel.text = "Length: \(lengthWidthRounded)"
                
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
                            makeVertical.isHidden = false
                            resetSize.isHidden = false
                            widthLabel.isHidden = false
                            lengthLabel.isHidden = false
                            
                            // Update material for old object.
                            if (selectedPoster != -1) {
                                guard selectedPoster < posterNodeRefereneces.count, let oldPointer = posterNodeRefereneces.pointer(at: selectedPoster) else { return }
                                let oldHit = Unmanaged<SCNNode>.fromOpaque(oldPointer).takeUnretainedValue()
                                let unhighlightMat = SCNMaterial()
                                
                                if (posterImageNameArray[selectedPoster] == "noImage") {
                                    unhighlightMat.diffuse.contents = UIImage(named: "arewecool")
                                } else {
                                    let selectedImage = UIImage(contentsOfFile: posterImageNameArray[selectedPoster])
                                    unhighlightMat.diffuse.contents = selectedImage
                                }
                                
                                unhighlightMat.isDoubleSided = true
                                oldHit.geometry?.materials[0] = unhighlightMat
                            }
                            
                            // Update material for newly selected object.
                            let highlightMat = SCNMaterial()
                            
                            
                            
                            if (posterImageNameArray[n] == "noImage") {
                                highlightMat.diffuse.contents = UIImage(named: "arewecool")
                            } else {
                                let selectedImage = UIImage(contentsOfFile: posterImageNameArray[n])
                                highlightMat.diffuse.contents = selectedImage
                            }
                            
                            highlightMat.isDoubleSided = true
                            highlightMat.emission.contents = UIColor.yellow.withAlphaComponent(0.1)
                            hit.node.geometry?.materials[0] = highlightMat
                            
                            // Width n Length stuff
                            let nodeWidth = (hit.node.boundingBox.max.x - hit.node.boundingBox.min.x) * 100 * hit.node.scale.x
                            let nodeWidthRounded = String(format: "%.1f", nodeWidth)
                            let nodeLength = (hit.node.boundingBox.max.y - hit.node.boundingBox.min.y) * 100 * hit.node.scale.y
                            let lengthWidthRounded = String(format: "%.1f", nodeLength)
                            widthLabel.text = "Width: \(nodeWidthRounded)"
                            lengthLabel.text = "Length: \(lengthWidthRounded)"
                            
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
                    
                    
                    if (posterImageNameArray[selectedPoster] == "noImage") {
                        unhighlightMat.diffuse.contents = UIImage(named: "arewecool")
                    } else {
                        let selectedImage = UIImage(contentsOfFile: posterImageNameArray[selectedPoster])
                        unhighlightMat.diffuse.contents = selectedImage
                    }
                    
                
                    unhighlightMat.isDoubleSided = true
                    oldHit.geometry?.materials[0] = unhighlightMat
                    
                    // Hide delete button.
                    deleteButton.isHidden = true
                    makeVertical.isHidden = true
                    resetSize.isHidden = true
                    widthLabel.isHidden = true
                    lengthLabel.isHidden = true
                    
                    // Unselect posters.
                    selectedPoster = -1
                } else {
                    let hitList = sceneView.hitTest(location,
                    types: .existingPlaneUsingGeometry)
                    
                    if let hit = hitList.first {
                        
                        var posterGeo = SCNPlane(width: 0.05, height: 0.1)
                        let posterMat = SCNMaterial()
                        
                        
                        if let data = UserDefaults.standard.string(forKey: "SelectedImage"), let image = UIImage(contentsOfFile: data) {
                            
                            let multFactor = image.size.height / 10
                            let widthMulted = image.size.width / multFactor
                            
                            posterGeo = SCNPlane(width: widthMulted / 100, height: 0.1)
                            print(widthMulted)
                            
                            posterMat.diffuse.contents = image
                            
                            if let selectedImagePath = UserDefaults.standard.string(forKey: "SelectedImage") {
                                posterImageNameArray.append(selectedImagePath)
                            } else {
                                posterImageNameArray.append("noImage")
                            }
                        } else {
                            // no image selected
                            print("no image selected")
                        }
                        
                        
                        posterMat.isDoubleSided = true
                        posterGeo.materials = [posterMat]
                        
                        let posterNode = SCNNode(geometry: posterGeo)
                        posterNode.transform = SCNMatrix4(hit.anchor!.transform)
                        posterNode.eulerAngles = SCNVector3(posterNode.eulerAngles.x + (-Float.pi / 2), posterNode.eulerAngles.y, posterNode.eulerAngles.z)
                        posterAnglesArray.append(posterNode.eulerAngles)
                        posterNode.position = SCNVector3(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
                    
                        // Add Poster!
                        posterNode.name = "MyPoster"
                        
                        // BUG: Starting here
                        let pointer = Unmanaged.passUnretained(posterNode).toOpaque()
                        posterNodeRefereneces.addPointer(pointer)
                        sceneView.scene.rootNode.addChildNode(posterNode)
                        
                        
                    } else {
                        if (!showingInvalid) {
                            DispatchQueue.main.async {
                                self.showingInvalid = true
                                self.invalidPlaneLabel.isHidden = false
                                self.invalidPlaneLabel.alpha = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                                    self.invalidPlaneLabel.alpha = 0.0
                                }, completion: { (isCompleted) in
                                    self.invalidPlaneLabel.isHidden = true
                                    self.showingInvalid = false
                                })
                            }
                        }
                    }
                }
            }
        default:
            print("tapped default")
        }
    }
    
}

extension UIColor {
    open class var planeColor: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.0)
    }
}
