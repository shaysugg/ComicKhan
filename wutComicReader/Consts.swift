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


let validComicFormats = ["pdf", "cbz", "cbr"]
let validImageFormats = ["jpeg", "jpg", "png"]

enum CollectioViewIDs {
    case comicCell
    case comicGroupHeader
    
    var id: String {
        switch self {
        case .comicCell: return "comic-cell"
        case .comicGroupHeader: return "comic-group-header"
        }
    }
}

extension NSNotification.Name {
    static let newGroupAboutToAdd = NSNotification.Name(rawValue: "new group added")
    static let reloadLibraryAtIndex = NSNotification.Name(rawValue: "reload library at")
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

