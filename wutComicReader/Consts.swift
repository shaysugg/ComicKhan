//
//  Consts.swift
//  wutComicReader
//
//  Created by Shayan on 6/8/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit


//var appDirectory : URL?
let appFontBold = "HelveticaNeue-Bold"
let appFontMeduim = "HelveticaNeue-Bold"
let appFontRegular = "HelveticaNeue"


extension NSNotification.Name {
    static let newGroupAdded = NSNotification.Name(rawValue: "new group added")
    static let reloadLibraryAtIndex = NSNotification.Name(rawValue: "reload library at")
}

enum HelvetincaNeueFont {
    case regular
    case light
    case thin
    case medium
    case bold
    
    var name: String {
        switch self {
        case .light:
            return "HelveticaNeue-Light"
        case .thin:
            return "HelveticaNeue-Thin"
        case .bold:
            return "HelveticaNeue-Bold"
        case .regular:
            return "HelveticaNeue"
        case .medium:
            return "HelveticaNeue-Medium"
        }
    }
}


//["HelveticaNeue-UltraLightItalic", "HelveticaNeue-Medium", "HelveticaNeue-MediumItalic", "HelveticaNeue-UltraLight", "HelveticaNeue-Italic", "HelveticaNeue-Light", "HelveticaNeue-ThinItalic", "HelveticaNeue-LightItalic", "HelveticaNeue-Bold", "HelveticaNeue-Thin", "HelveticaNeue-CondensedBlack", "HelveticaNeue", "HelveticaNeue-CondensedBold", "HelveticaNeue-BoldItalic"
