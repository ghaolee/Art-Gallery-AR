//
//  PathView.swift
//  EmmaTang-Lab3
//
//  Created by Emma Tang on 9/30/19.
//  Copyright © 2019 Emma Tang. All rights reserved.
//

import Foundation
import UIKit

class PathView: UIView {
    
    var pathLine: Path?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func midpoint(first: CGPoint, second: CGPoint) -> CGPoint {
        let xPoint = (first.x + second.x)/2
        let yPoint = (first.y + second.y)/2
        return CGPoint(x: xPoint, y: yPoint)
    }
    private func createQuadPath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath() //Create the path object
        if(points.count < 2){ //There are no points to add to this path
            return path
        }
        path.move(to: points[0]) //Start the path on the first point
        for i in 1..<points.count - 1{
            let firstMidpoint = midpoint(first: path.currentPoint, second:
                points[i])
            //Get midpoint between the path's last point and the next one in the array
            let secondMidpoint = midpoint(first: points[i], second:
                points[i+1])
            //Get midpoint between the next point in the array and the one  after it
            path.addCurve(to: secondMidpoint, controlPoint1: firstMidpoint,
                          controlPoint2: points[i]) //This creates a cubic Bezier curve using math!
        }
        return path
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if pathLine == nil {
            return
        }
        if pathLine!.points.count == 0{
            return
        }
        
        let aPath = createQuadPath(points: pathLine!.points)
        if pathLine!.points.count <= 2{
            aPath.fill(with:.normal, alpha: pathLine!.alpha)
        }
        
        aPath.lineJoinStyle = .round
        aPath.lineWidth = (pathLine!.thick)
        pathLine!.color.setStroke()
        aPath.stroke(with: .normal, alpha: pathLine!.alpha)
        
        let beganDot = UIBezierPath()
        beganDot.addArc(withCenter: pathLine!.points[0], radius: pathLine!.thick/2, startAngle: 0, endAngle: (CGFloat(Double.pi * 2)), clockwise: true)
        
        let endDot = UIBezierPath()
        endDot.addArc(withCenter: pathLine!.points[pathLine!.points.count - 1], radius: pathLine!.thick/2, startAngle: 0, endAngle: (CGFloat(Double.pi * 2)), clockwise: true)
        pathLine!.color.setFill()
        
        beganDot.fill(with: .normal, alpha: pathLine!.alpha)
        endDot.fill(with: .normal, alpha: pathLine!.alpha)

    }
    
}
