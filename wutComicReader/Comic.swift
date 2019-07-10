//
//  Comic.swift
//  wutComicReader
//
//  Created by Shayan on 5/31/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit

class Comic: NSObject {
    var cover: UIImage?
    let name: String
    let pageNumbers: Int
    let pages : [UIImage]
    
    init(cover : UIImage? , name : String , pageNumbers : Int , pages : [UIImage]) {
        self.cover = cover
        self.name = name
        self.pageNumbers = pageNumbers
        self.pages = pages
    }
}
