//
//  ViewController.swift
//  ZhiShenYong-Lab3
//
//  Created by Zhi Shen Yong on 9/24/19.
//  Copyright © 2019 Zhi Shen Yong. All rights reserved.
//

import UIKit
import ColorSlider

class DrawController: UIViewController {
    
    // Variables
    // =================================
    
    // Other globals
    var myCanvas: CanvasView!
    var currentLine: [CGPoint] = []
    var selectedColor = UIColor.black
    
    // Text Modal
    var amPuttingText = false
    var typingText = false
    var textPoint: CGPoint?
    
    // Slider Stuff
    let penColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    let backgroundColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    @IBOutlet weak var penThickness: UISlider!
    @IBOutlet weak var penOpacity: UISlider!
    
    // Outlets
    // =================================
    
    // Swiping UIViews
    @IBOutlet weak var drawView: UIView!
    @IBOutlet weak var swipeContainer: UIView!
    @IBOutlet weak var toolsView: UIView!
    
    // Default requirements
    // @IBOutlet weak var strokeWidthSliderOutlet: UISlider!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var undoButtonOutlet: UIButton!
    @IBOutlet weak var redoButtonOutlet: UIButton!
    
    // Actions
    // =================================
    
    // Clear the screen of lines and text.
    @IBAction func clearButtonAction(_ sender: Any) {
        myCanvas.lines.removeAll()
        myCanvas.linesUndone.removeAll()
    }
    
    // If there are elements drawn on the screen, remove the most recent addition
    // and add it to a temporary redo list.
    @IBAction func undoButtonAction(_ sender: Any) {
        if (myCanvas.lines.count > 0) {
            myCanvas.linesUndone.append(myCanvas.lines.popLast()!)
        }
    }
    
    // If there are elements in the redo list, remove the most recent addition
    // and add it back to the main elements list.
    @IBAction func redoButtonAction(_ sender: Any) {
        if (myCanvas.linesUndone.count > 0) {
            myCanvas.lines.append(myCanvas.linesUndone.popLast()!)
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        let saveAlert = UIAlertController(title: "Save", message: "Save This Drawing?", preferredStyle: .alert)
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        saveAlert.addAction(UIAlertAction(title:"Save", style: .default, handler: { alert -> Void in
            let image = UIGraphicsImageRenderer(bounds: self.myCanvas.bounds).image { _ in
                self.myCanvas.drawHierarchy(in: self.myCanvas.bounds, afterScreenUpdates: true)
            }
            if let data = image.pngData() {
                UserDefaults.standard.set(data, forKey: "drawings")
            }
        }))
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    // Other Functions
    // ============================================
    
    // Set custom CanvasView as a whole-frame SubView.
    // Bring a number of existing UI Elements to the front.
    // Make color buttons round.
    // Hide sliding panels and set relevant background color.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newFrame = CGRect(x: 0, y: 0, width: drawView.frame.width, height: drawView.frame.height)
        myCanvas = CanvasView(frame: newFrame)
        drawView.addSubview(myCanvas)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.didPanScene(withGestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
        myCanvas.addGestureRecognizer(panGesture)
        
        view.bringSubviewToFront(clearButtonOutlet)
        view.bringSubviewToFront(undoButtonOutlet)
        view.bringSubviewToFront(redoButtonOutlet)
        
        // Cocoapods Color sliders
        penColorSlider.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        penColorSlider.center = CGPoint(x: 80 + view.frame.width/2, y: view.frame.height - 119)
        penColorSlider.addTarget(self, action: #selector(penChangedColor), for: .valueChanged)
        view.addSubview(penColorSlider)
        
        backgroundColorSlider.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        backgroundColorSlider.center = CGPoint(x: 80 + view.frame.width/2, y: view.frame.height - 56)
        backgroundColorSlider.addTarget(self, action: #selector(backgroundChangedColor), for: .valueChanged)
        view.addSubview(backgroundColorSlider)
    }
    
    @objc func penChangedColor(_ slider: ColorSlider){
        let color = slider.color
        selectedColor = color
    }
    @objc func backgroundChangedColor(_ slider: ColorSlider){
        let color = slider.color
        myCanvas.backgroundColor = color
    }
    
    @objc func didPanScene(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let touchPoint = recognizer.location(in: view)
            currentLine.removeAll()
            currentLine.append(touchPoint)
            myCanvas.lines.append(Line(points: currentLine, width: CGFloat(penThickness!.value), color: selectedColor, opacity: CGFloat(penOpacity!.value)))
            myCanvas.linesUndone.removeAll()
        case .changed:
            let touchPoint = recognizer.location(in: view)
            currentLine.append(touchPoint)
            myCanvas.lines[myCanvas.lines.count - 1].points = currentLine
        case .ended:
            let touchPoint = recognizer.location(in: view)
            currentLine.append(touchPoint)
            myCanvas.lines[myCanvas.lines.count - 1].points = currentLine
        default:
            print("debug")
        }

    }
}

