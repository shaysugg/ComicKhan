//
//  Colors.swift
//  wutComicReader
//
//  Created by Sha Yan on 11/26/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var appQuaternarySystemFill : UIColor {
        if #available(iOS 13.0, *) {
            return .quaternarySystemFill
        }else{
            return .red
        }
    }
    
    static var appMainLabelColor : UIColor {
           if #available(iOS 13.0, *) {
               return .label
           }else{
                return .black
           }
       }
    
    static var appSeconedlabelColor : UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        }else{
            return #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
        }
    }
    
    static var appSystemBackground : UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        }else{
            return .white
        }
    }
    
    static var appSystemSecondaryBackground : UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        }else{
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    static var appBlue : UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(red:0.12, green:0.34, blue:0.63, alpha:1.0)
        }else{
            return UIColor(red:0.12, green:0.34, blue:0.63, alpha:1.0)
        }
    }
    
    static var appShadowColor : UIColor {
        if #available(iOS 13.0, *) {
            return .black
        }else{
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    
    
}
