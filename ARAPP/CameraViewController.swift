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
    
    var maxPosters: Int = 2;
    var numPosters: Int = 0;
    var canPlacePoster: Bool = true
    var posterNodeRefereneces = NSPointerArray.weakObjects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up scene view
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
        // Adopt delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Add tap gesture
        // TODO: you can tap on poster to put anohter poster on it!
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.didTapScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add pinch gesture
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    @objc func didTapScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            let location = recognizer.location(ofTouch: 0,
                                            in: sceneView)
        
            if (canPlacePoster) {
                
                let hitList = sceneView.hitTest(location,
                types: .existingPlaneUsingGeometry)
                
                if let hit = hitList.first {
                    
                    // TODO: Edit SCNPlane width and height to change poster size.
                    let posterGeo = SCNPlane(width: 0.05, height: 0.1)
                    let posterMat = SCNMaterial()
                    posterMat.diffuse.contents = UIImage(named: "arewecool")
                    posterGeo.materials = [posterMat]
                    
                    // TODO: Edit eulerAngles to rotate the poster.
                    let posterNode = SCNNode(geometry: posterGeo)
                    posterNode.transform = SCNMatrix4(hit.anchor!.transform)
                    posterNode.eulerAngles = SCNVector3(posterNode.eulerAngles.x + (-Float.pi / 2), posterNode.eulerAngles.y, posterNode.eulerAngles.z)
                    posterNode.position = SCNVector3(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
                
                    // Add Poster!
                    posterNode.name = "MyPoster"
                    
                    let pointer = Unmanaged.passUnretained(posterNode).toOpaque()
                    posterNodeRefereneces.addPointer(pointer)
                    
                    numPosters = numPosters + 1
                    if (numPosters >= maxPosters) {
                        canPlacePoster = false
                    }
                    
                    sceneView?.scene.rootNode.addChildNode(posterNode)
                    
                } else {
                    print("Not on valid plane!")
                }
            } else {
                
                // Get a list of nodes hit.
                let hitList = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
                
                // Find the first node that has the designated name.
                // Potential for error here but assume we can't have overlapping posters.
                for hit in hitList.filter( { $0.node.name != nil }) {
                    if hit.node.name == "MyPoster" {
                        
                        // Check the references for
                        for n in 0 ..< posterNodeRefereneces.count {
                            
                            // This should never return (because why?)
                            guard n < posterNodeRefereneces.count, let pointer = posterNodeRefereneces.pointer(at: n) else { return }
                            
                            // Get the object at the pointer.
                            let referencedHit = Unmanaged<SCNNode>.fromOpaque(pointer).takeUnretainedValue()
                            
                            // Check if object at pointer is truly the hit poster.
                            if (referencedHit === hit.node) {
                                // Try rotating the node
                                hit.node.eulerAngles = SCNVector3(hit.node.eulerAngles.x, hit.node.eulerAngles.y + (Float.pi / 2), hit.node.eulerAngles.z)
                            }
                        }

                    }
                }
                
            }
        default:
            print("tapped default")
        }
    }
    
    @objc func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        print(gesture.scale)
    }
    
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.5)
    }
}
