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
    
    static var appSystemBackground : UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .secondarySystemBackground
                }else{
                    return .systemBackground
                }
            }
        }else{
            return .white
        }
    }()
    
    static var appSystemSecondaryBackground : UIColor = {
        if #available(iOS 13.0, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return .systemFill
                    }else{
                        return .secondarySystemFill
                    }
                }
        }else{
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }()
    
    static var appSecondaryLabel : UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        }else{
            return .gray
        }
    }
    
    static var appShadowColor : UIColor {
        if #available(iOS 13.0, *) {
            return .black
        }else{
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    
    static let appBlueColor = UIColor(named: "appBlueColor")
}
