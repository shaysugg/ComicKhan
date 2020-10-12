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


let validComicFormats = ["pdf", "cbz", "cbr"]
let validImageFormats = ["jpeg", "jpg", "png"]

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

var previouseOriantation: UIDeviceOrientation? {
    didSet{
        if previouseOriantation!.isLandscape {
        print("landscaped")
        }else if previouseOriantation!.isPortrait {
                print("portriat")
            }else{
                print("flat")
            }
    }
}

