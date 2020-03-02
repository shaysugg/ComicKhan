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
                        return .systemBackground
                    }else{
                        return .secondarySystemBackground
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
    
    static var appProgressColor : UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.03297975659, green: 0.1976064146, blue: 0.2944883406, alpha: 1)
                }else{
                    return #colorLiteral(red: 0.4221869409, green: 0.6506024003, blue: 0.8026198745, alpha: 1)
                }
            }
        }else{
             return #colorLiteral(red: 0.03297975659, green: 0.1976064146, blue: 0.2944883406, alpha: 1)
        }
    }()
    
    static var appTrackProgressColor : UIColor = {
           if #available(iOS 13.0, *) {
               return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                   if UITraitCollection.userInterfaceStyle == .dark {
                       return #colorLiteral(red: 0.2186438143, green: 0.4104945064, blue: 0.5327916145, alpha: 1)
                   }else{
                       return #colorLiteral(red: 0.03621871024, green: 0.1935892105, blue: 0.2905158401, alpha: 1)
                   }
               }
           }else{
                return #colorLiteral(red: 0.03297975659, green: 0.1976064146, blue: 0.2944883406, alpha: 1)
           }
       }()
    
    static let appBlueColor = UIColor(named: "appBlueColor")
}
