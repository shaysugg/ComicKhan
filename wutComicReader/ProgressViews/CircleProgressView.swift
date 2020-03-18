//
//  CircleProgressView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/19/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressView: UIView {
    
    //MARK:- Variables
    
    private lazy var progressCircleShape = CAShapeLayer()
    private lazy var backgroundCircleShape = CAShapeLayer()
    private var backgroundCircleRect: CGRect?
    
    var trackCircleColor: CGColor? {
        didSet{
            backgroundCircleShape.fillColor = trackCircleColor
        }
    }
    
    var progressCircleColor: CGColor? {
        didSet{
            progressCircleShape.fillColor = progressCircleColor
        }
    }
    
    var progressValue: CGFloat? {
        didSet{
            layoutSubviews()
        }
    }
    
    var strokeWidth: CGFloat = 0
    
    //MARK:- Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    override func layoutSubviews() {
        drawBackgroundCircle()
        if let value = progressValue {
            drawProgressCircle(withProgress: value)
        }
    }
    
    convenience init(withProgress value: CGFloat, InnerStroke: CGFloat = 0){
        self.init()
        self.strokeWidth = InnerStroke
        self.progressValue = value
    }
    
    private func drawProgressCircle(withProgress value: CGFloat){
        guard 0 <= value && value <= 1 else { return }
        progressCircleShape.removeFromSuperlayer()

        let circle = UIBezierPath()
        let center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        circle.move(to: center)
        circle.addArc(withCenter: center,
                      radius: frame.size.height / 2 - strokeWidth,
                      startAngle: -(CGFloat.pi * 0.5),
                      endAngle: -(CGFloat.pi * 0.5) + 2 * value * CGFloat.pi,
                      clockwise: true)
        
        progressCircleShape.path = circle.cgPath
        progressCircleShape.fillColor = progressCircleColor ?? defaultBlueColor.cgColor
        layer.addSublayer(progressCircleShape)
        scaleToBounds(progressCircleShape)
        
    }
    
    private func drawBackgroundCircle(){
        let center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        let circle = UIBezierPath(arcCenter: center,
                                  radius: frame.size.height / 2,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        
        backgroundCircleShape.path = circle.cgPath
        backgroundCircleShape.fillColor = trackCircleColor ?? defaultGrayColor.cgColor
        layer.addSublayer(backgroundCircleShape)
        
        backgroundCircleRect = circle.cgPath.boundingBox
        scaleToBounds(backgroundCircleShape)
    }
    
    private func scaleToBounds(_ shape:CAShapeLayer){
        let xScale = bounds.width / backgroundCircleRect!.width
        let yScale = bounds.height / backgroundCircleRect!.height
        shape.transform = CATransform3DMakeScale(xScale, yScale, 1.0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK:- Defaults Colors
    
    private var defaultBlueColor : UIColor = {
           if #available(iOS 13.0, *) {
               return .systemBlue
           }else{
               return .blue
           }
       }()


       private var defaultGrayColor : UIColor = {
           if #available(iOS 13.0, *) {
               return .systemGray4
           }else{
               return .lightGray
           }
       }()
  
}

