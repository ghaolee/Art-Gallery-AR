//
//  ViewController.swift
//  EmmaTang-Lab3
//
//  Created by Emma Tang on 9/26/19.
//  Copyright © 2019 Emma Tang. All rights reserved.
//

import UIKit
import ColorSlider

class ViewController: UIViewController {
 
    let penColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    let backgroundColorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    var currentPath: PathView?
    var currentColor: UIColor!
    var currentThickness: CGFloat!
    var currentAlpha: CGFloat!
    var allPaths: [PathView] = [PathView]()
    var redos: [PathView] = [PathView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentThickness = 15
        currentAlpha = 1
        currentColor = UIColor.black
 
    //https://cocoapods.org/pods/ColorSlider
        penColorSlider.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        penColorSlider.center = CGPoint(x: 50+view.frame.width/2, y: view.frame.height - 100)
        penColorSlider.addTarget(self, action: #selector(penChangedColor), for: .valueChanged)
        view.addSubview(penColorSlider)
        
        backgroundColorSlider.frame = CGRect(x: 0, y: 0, width: 150, height: 20)
        backgroundColorSlider.center = CGPoint(x: 50+view.frame.width/2, y: view.frame.height-50)
        backgroundColorSlider.addTarget(self, action: #selector(backgroundChangedColor), for: .valueChanged)
        view.addSubview(backgroundColorSlider)
        // Do any additional setup after loading the view.
    }
    @objc func penChangedColor(_ slider: ColorSlider){
        let color = slider.color
        currentColor = color
    }
    @objc func backgroundChangedColor(_ slider: ColorSlider){
        let color = slider.color
        view.backgroundColor = color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = (touches.first)!.location(in: view) as CGPoint
        //redos = [PathView] ()
        
        let mainFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-150)
        
        currentPath = PathView(frame: mainFrame)
        
        currentPath!.pathLine = Path(color: currentColor, thick: currentThickness, points: [touchPoint], alpha: currentAlpha)
        
        view.addSubview(currentPath!)
        //print("touches began")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = (touches.first)!.location(in: view) as CGPoint
        
        if currentPath == nil {
            return
        }
        
        currentPath!.pathLine?.points.append(touchPoint)
        //print("touches moved")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = (touches.first)!.location(in: view) as CGPoint
        
        if currentPath == nil {
            return
        }
        
        currentPath!.pathLine?.points.append(touchPoint)
        allPaths.append(currentPath!)
        currentPath = nil
        //print("touches ended")
    }

    @IBAction func undoButton(_ sender: Any) {
        if allPaths.count > 0 {
            redos.append(allPaths.last!)
            allPaths.removeLast().removeFromSuperview()
        }
        //print("undo pressed")
    }
    
    @IBAction func clearButton(_ sender: Any) {
        for i in allPaths{
            i.removeFromSuperview()
        }
        //print("clear pressed")
    }

   
    @IBAction func redoButton(_ sender: Any) {
        if redos.count > 0{
            view.addSubview(redos.last!)
            allPaths.append(redos.last!)
        }
    }
    
    @IBAction func thicknessSlider(_ sender: UISlider) {
        currentThickness = CGFloat(sender.value)
        //print(CGFloat(currentThickness))
    }
    @IBAction func opacitySlider(_ sender: UISlider) {
        currentAlpha = CGFloat(sender.value)
        print(CGFloat(currentAlpha))
    }
    
//    @IBAction func blackColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
//
//    @IBAction func blueColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
//
//    @IBAction func pinkColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
//
//    @IBAction func purpleColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
//
//    @IBAction func greenColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
//
//    @IBAction func yellowColor(_ sender: UIButton) {
//        currentColor = sender.backgroundColor
//    }
}

