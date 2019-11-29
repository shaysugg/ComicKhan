//
//  Helper.swift
//  wutComicReader
//
//  Created by Shayan on 7/10/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeDropShadow(scale: Bool = true , shadowOffset: CGSize , opacity: Float, radius: Int) {
        layer.shadowColor = UIColor.appShadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = 5
        layer.shadowOpacity = opacity
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    func deviceModel(){
//        UIDevice().type
    }
    

   
    func presentCostomAlert( hasTextfield : Bool , title: String? ,text: String , buttonTexts : [String] ){
//        self.bounds.width * 0.7
//        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
//        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//        backgroundView.
//
//        self.addSubview(backgroundView)
//        backgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        backgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//
//
//        let alertView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
//        alertView.backgroundColor = .white
        
//        let alert = UIAlertController(title: title, message: text, preferredStyle: .actionSheet)
//        let action = UIAlertAction(title: <#T##String?#>, style: <#T##UIAlertAction.Style#>, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
        
    }
}



extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
