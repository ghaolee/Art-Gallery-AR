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
    
    
    // Other globals
    var myCanvas: CanvasView!
    var currentLine: [CGPoint] = []
    var selectedColor = UIColor.black
    
    // Text Modal
    var amPuttingText = false
    var textPoint: CGPoint?
    
    // Slider Stuff
    let penColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    let backgroundColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    @IBOutlet weak var penThickness: UISlider!
    @IBOutlet weak var penOpacity: UISlider!
    
    
    // Swiping UIViews
    @IBOutlet weak var drawView: UIView!
    @IBOutlet weak var swipeContainer: UIView!
    @IBOutlet weak var toolsView: UIView!
    
    // Default requirements
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var undoButtonOutlet: UIButton!
    @IBOutlet weak var redoButtonOutlet: UIButton!
    @IBOutlet weak var brushOrText: UISegmentedControl!
    
    @IBAction func clearButtonAction(_ sender: Any) {
        myCanvas.lines.removeAll()
        myCanvas.linesUndone.removeAll()
        myCanvas.words.removeAll()
        myCanvas.wordsUndone.removeAll()
        myCanvas.lineOrWord.removeAll()
        myCanvas.lineOrWordUndone.removeAll()
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        if (myCanvas.lineOrWord.count > 0) {
            let which = myCanvas.lineOrWord.popLast()!
            if (which == "line") {
                if (myCanvas.lines.count > 0) {
                    myCanvas.linesUndone.append(myCanvas.lines.popLast()!)
                    myCanvas.lineOrWordUndone.append("line")
                }
            } else {
                if (myCanvas.words.count > 0) {
                    myCanvas.wordsUndone.append(myCanvas.words.popLast()!)
                    myCanvas.lineOrWordUndone.append("word")
                }
            }
        }
    }
    
    // If there are elements in the redo list, remove the most recent addition
    // and add it back to the main elements list.
    @IBAction func redoButtonAction(_ sender: Any) {
        if (myCanvas.lineOrWordUndone.count > 0) {
            let which = myCanvas.lineOrWordUndone.popLast()!
            if (which == "line") {
                if (myCanvas.linesUndone.count > 0) {
                    myCanvas.lines.append(myCanvas.linesUndone.popLast()!)
                    myCanvas.lineOrWord.append("line")
                }
            } else {
                if (myCanvas.wordsUndone.count > 0) {
                    myCanvas.words.append(myCanvas.wordsUndone.popLast()!)
                    myCanvas.lineOrWord.append("word")
                }
            }
        }
    }
    
    // Switch between Brush and Text
    @IBAction func switchBrushOrText(_ sender: Any) {
        switch brushOrText.selectedSegmentIndex {
        case 0:
            amPuttingText = false
        case 1:
            amPuttingText = true
        default:
            break
        }
    }
    
    // Save Image
    // TODO -- Connect to Middle View
    @IBAction func saveImage(_ sender: Any) {
        let saveAlert = UIAlertController(title: "Save", message: "Save This Drawing?", preferredStyle: .alert)
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        saveAlert.addAction(UIAlertAction(title:"Save", style: .default, handler: { alert -> Void in
            let image = UIGraphicsImageRenderer(bounds: self.myCanvas.bounds).image { _ in
                self.myCanvas.drawHierarchy(in: self.myCanvas.bounds, afterScreenUpdates: true)
            }
            if let data = image.pngData() {
                let image = UIImage(data: data)
                var counter = UserDefaults.standard.integer(forKey: "imageNameCounter")
                counter += 1
                let paths = URL(fileURLWithPath: NSHomeDirectory())
                let fileName = "/Documents/PosterImages/\(counter).png"
                let filePath = paths.appendingPathComponent(fileName)
                UserDefaults.standard.set(counter, forKey: "imageNameCounter")
                do {
                    try image!.pngData()?.write(to: filePath, options: .atomic)
                    print("SUCCESS:", filePath)
                }
                catch let error{
                    print(error)
                }
                // UserDefaults.standard.set(data, forKey: "drawings")
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
        penColorSlider.frame = CGRect(x: 0, y: 0, width: 130, height: 20)
        penColorSlider.center = CGPoint(x: 120 + view.frame.width/2, y: view.frame.height - 108)
        penColorSlider.addTarget(self, action: #selector(penChangedColor), for: .valueChanged)
        view.addSubview(penColorSlider)
        
        backgroundColorSlider.frame = CGRect(x: 0, y: 0, width: 130, height: 20)
        backgroundColorSlider.center = CGPoint(x: 120 + view.frame.width/2, y: view.frame.height - 52)
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
    
    func showAddText() {
        let textController = UIAlertController(title: "Add Text", message: "", preferredStyle: .alert)
        textController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "Enter Text"
        })
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
            let inputText = textController.textFields![0] as UITextField
            if (!inputText.text!.isEmpty) {
                self.myCanvas.words.append(Words(text: inputText.text!, color: self.selectedColor, fontSize: Int(self.penThickness.value * 2), coordinates: self.textPoint!, opacity: CGFloat(self.penOpacity!.value)))
                self.myCanvas.lineOrWord.append("word")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { alert -> Void in
            print("nothing")
        })
        textController.addAction(cancelAction)
        textController.addAction(addAction)
        self.present(textController, animated: true, completion: nil)
    }
    
    func fingerDown(touchPoint: CGPoint) {
        currentLine.removeAll()
        currentLine.append(touchPoint)
        myCanvas.lines.append(Line(points: currentLine, width: CGFloat(penThickness!.value), color: selectedColor, opacity: CGFloat(penOpacity!.value)))
        myCanvas.linesUndone.removeAll()
        myCanvas.wordsUndone.removeAll()
        myCanvas.lineOrWordUndone.removeAll()
        if (!amPuttingText) {
            myCanvas.lineOrWord.append("line")
        }
    }
    
    func fingerMove(touchPoint: CGPoint) {
        currentLine.append(touchPoint)
        myCanvas.lines[myCanvas.lines.count - 1].points = currentLine
    }
    
    func fingerLift(touchPoint: CGPoint) {
        if (!amPuttingText) {
            currentLine.append(touchPoint)
            myCanvas.lines[myCanvas.lines.count - 1].points = currentLine
        } else {
            textPoint = touchPoint
            showAddText()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!amPuttingText) {
            guard let touchPoint = touches.first?.location(in: myCanvas) else { return }
            fingerDown(touchPoint: touchPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!amPuttingText) {
            guard let touchPoint = touches.first?.location(in: myCanvas) else { return }
            fingerMove(touchPoint: touchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: myCanvas) else { return }
        fingerLift(touchPoint: touchPoint)
    }
    
    @objc func didPanScene(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if (!amPuttingText) {
                let touchPoint = recognizer.location(in: myCanvas)
                fingerDown(touchPoint: touchPoint)
            }
        case .changed:
            if (!amPuttingText) {
                let touchPoint = recognizer.location(in: myCanvas)
                fingerMove(touchPoint: touchPoint)
            }
        case .ended:
            let touchPoint = recognizer.location(in: myCanvas)
            fingerLift(touchPoint: touchPoint)
        default:
            print("default")
        }

    }
}

