//
//  ViewController.swift
//  ARAPP
//
//  Created by Zhi Shen Yong on 11/1/19.
//  Copyright © 2019 Zhi Shen Yong. All rights reserved.
//

import UIKit

class AppContainer: UIViewController, UIScrollViewDelegate {
    
    class func containerViewWidth(_ leftVC: UIViewController, middleVC: UIViewController, rightVC: UIViewController) -> AppContainer {
        
        let container = AppContainer()
        
        container.leftVC = leftVC
        container.middleVC = middleVC
        container.rightVC = rightVC
        
        return container
    }
    
    var leftVC: UIViewController!
    var middleVC: UIViewController!
    var rightVC: UIViewController!
    
    var horizontalViews = [UIViewController]()
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupHorizontalScrollView()
    }
    
    func setupHorizontalScrollView() {
        
        // Section
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        scrollView.alwaysBounceHorizontal = false
        
        // Section
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        // Section
        scrollView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        self.view.addSubview(scrollView)
        
        // Section
        let scrollWidth = 3 * view.width
        let scrollHeight = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        // Section
        leftVC.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        addChild(leftVC)
        scrollView.addSubview(leftVC.view)
        leftVC.didMove(toParent: self)
        middleVC.view.frame = CGRect(x: view.width, y: 0, width: view.width, height: view.height)
        addChild(middleVC)
        scrollView.addSubview(middleVC.view)
        middleVC.didMove(toParent: self)
        rightVC.view.frame = CGRect(x: 2 * view.width, y: 0, width: view.width, height: view.height)
        addChild(rightVC)
        scrollView.addSubview(rightVC.view)
        rightVC.didMove(toParent: self)
        
        // Section
        scrollView.contentOffset.x = middleVC.view.frame.origin.x
        scrollView.delegate = self
    }
    
    // Implement delegate
    // Check the offset to see which page we are in
    
}

