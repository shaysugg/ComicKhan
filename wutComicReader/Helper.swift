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
}

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

extension UIImage{
    convenience init?(_ comic: Comic? ,withImageName imageName: String?) {
        let comicname : String = comic?.name ?? ""
        let imagename: String = imageName ?? ""
        let appfileManager = AppFileManager()
        
        let path = appfileManager.comicDirectory.path + "/Extracted-" + comicname  + "/" + imagename
        self.init(contentsOfFile: path)
    }
}


