//
//  Helper.swift
//  wutComicReader
//
//  Created by Shayan on 7/10/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



extension UIView {
    
    func makeDropShadow(scale: Bool = true , shadowOffset: CGSize , opacity: Float, radius: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func makeBoundsDropShadow(shadowOffset: CGSize , opacity: Float, radius: CGFloat) {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowPath = shadowPath.cgPath
    }
}

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

class ZoomGestureRecognizer: UITapGestureRecognizer {
    var point: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        point = touches.first?.location(in: view)
    }
}
