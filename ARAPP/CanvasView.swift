//
//  CanvasView.swift
//  ZhiShenYong-Lab3
//
//  Created by Zhi Shen Yong on 9/24/19.
//  Copyright © 2019 Zhi Shen Yong. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    // Variables
    // ===========================
    var lines: [Line] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    var linesUndone: [Line] = []
    
    var words: [Words] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    var wordsUndone: [Words] = []
    var lineOrWord: [String] = []
    var lineOrWordUndone: [String] = []
    
    // Initialization
    // =================================
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Other Functions
    // ==================================
    
    // Custom draw function. Draw every word in the word array
    // and draw every line in the line array.
    override func draw(_ rect: CGRect) { // BREAK
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        var lineCounter = 0
        var wordCounter = 0
        
        for wordOrLine in lineOrWord {
            if (wordOrLine == "line") {
                let line = lines[lineCounter]
                line.color.setStroke()
                line.color.setFill()
                let path = createQuadPath(points: line.points)
                if (line.points.count < 3) {
                    path.addArc(withCenter: line.points[0], radius: (line.width / 2), startAngle: 0, endAngle: CGFloat(Float.pi * 2), clockwise: true)
                    path.fill(with: .normal, alpha: line.opacity)
                } else {
                    path.lineCapStyle = .round
                    path.lineJoinStyle = .round
                    path.lineWidth = line.width
                    path.stroke(with: .normal, alpha: line.opacity)
                }
                if line.points.count > 1 {
                    for i in 1 ..< (line.points.count - 1) {
                        if ((line.points[i].y < line.points[i-1].y) && (line.points[i].y < line.points[i+1].y) && (line.points[i-1].x == line.points[i].x) && (line.points[i].x == line.points[i + 1].x)) || ((line.points[i].y > line.points[i-1].y) && (line.points[i].y > line.points[i+1].y) && (line.points[i-1].x == line.points[i].x) && (line.points[i].x == line.points[i + 1].x)) || ((line.points[i].x < line.points[i-1].x) && (line.points[i].x < line.points[i+1].x) && (line.points[i-1].y == line.points[i].y) && (line.points[i].y == line.points[i + 1].y)) ||
                            ((line.points[i].x > line.points[i-1].x) && (line.points[i].x > line.points[i+1].x) && (line.points[i-1].y == line.points[i].y) && (line.points[i].y == line.points[i + 1].y)) {
                            let newpath = UIBezierPath()
                            newpath.addArc(withCenter: line.points[i], radius: (line.width / 2), startAngle: 0, endAngle: CGFloat(Float.pi * 2), clockwise: true)
                            newpath.fill(with: .normal, alpha: line.opacity)
                        }
                    }
                }
                lineCounter = lineCounter + 1
            } else {
                let word = words[wordCounter]
                word.text.draw(with: CGRect(x: word.coordinates.x, y: word.coordinates.y, width: 500, height: 500), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont(name: "Arial", size: CGFloat(word.fontSize))!, NSAttributedString.Key.paragraphStyle: paragraph, NSAttributedString.Key.foregroundColor: word.color.withAlphaComponent(word.opacity)], context: nil)
                wordCounter = wordCounter + 1
            }
        }
    }
    
    // Helper function for calculating midpoint.
    private func midpoint(first: CGPoint, second: CGPoint) -> CGPoint {
        let midX = (first.x + second.x) / 2
        let midY = (first.y + second.y) / 2
        return CGPoint(x: midX, y: midY)
    }
    
    // Create a UIBezierPath with an array of points.
    private func createQuadPath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        if (points.count < 2) {
            return path
        }
        path.move(to: points[0])
        for i in 1 ..< points.count - 1 {
            let firstMidpoint = midpoint(first: path.currentPoint, second: points[i])
            let secondMidpoint = midpoint(first: points[i], second: points[i+1])
            path.addCurve(to: secondMidpoint, controlPoint1: firstMidpoint, controlPoint2: points[i])
        }
        return path
    }
    
}
