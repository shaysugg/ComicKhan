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
    static var appMainLabelColor : UIColor {
        return .label
    }
    
    static var appSeconedlabelColor : UIColor {
        return .secondaryLabel
    }
    
    static var appBackground : UIColor = {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .secondarySystemBackground
            }else{
                return .systemBackground
            }
        }
    }()
    
    static var appSecondaryBackground : UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .systemBackground
            }else{
                return .secondarySystemBackground
            }
        }
        
    }
    
    static var appSecondaryLabel : UIColor {
        return .secondaryLabel
    }
    
    static var appProgressColor : UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return #colorLiteral(red: 0.03297975659, green: 0.1976064146, blue: 0.2944883406, alpha: 1)
            }else{
                return #colorLiteral(red: 0.4221869409, green: 0.6506024003, blue: 0.8026198745, alpha: 1)
            }
        }
    }
    
    
    static var appMainSecondary : UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return #colorLiteral(red: 0.2186438143, green: 0.4104945064, blue: 0.5327916145, alpha: 1)
            }else{
                return #colorLiteral(red: 0.03621871024, green: 0.1935892105, blue: 0.2905158401, alpha: 1)
            }
        }
    }
    
    static let appMainColor = UIColor(named: "appBlueColor")!
}
