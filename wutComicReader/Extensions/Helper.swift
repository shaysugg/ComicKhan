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
    
    func makeDropShadow(scale: Bool = true , shadowOffset: CGSize , opacity: Float, radius: Int) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = 5
        layer.shadowOpacity = opacity
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
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


extension UIViewController {
    func appLaunchedForFirstTime() -> Bool {
        let didLaunchedBefore = UserDefaults.standard.bool(forKey: "appDidLunchedBefore")
        return !didLaunchedBefore 
    }
    
    func setAppDidLaunchedFlag() {
        UserDefaults.standard.set(true, forKey: "appDidLunchedBefore")
    }
}


extension BookReaderVC {
    func readerPresentForFirstTime() -> Bool {
        let didPresentBefore = UserDefaults.standard.bool(forKey: "readerDidPresentedBefore")
        if !didPresentBefore {
            UserDefaults.standard.set(true, forKey: "readerDidPresentedBefore")
            return true
        }else{
            return false
        }
    }
}
