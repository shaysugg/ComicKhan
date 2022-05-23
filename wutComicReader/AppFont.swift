//
//  AppFont.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/2/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import UIKit
protocol AppFont {
    var body: UIFont { get }
    var caption: UIFont { get }
    var caption2: UIFont { get }
    var h1: UIFont { get }
    var h2: UIFont { get }
    
}

struct SystemFont: AppFont {
    let body: UIFont = UIFont.preferredFont(forTextStyle: .body)
    
    let caption: UIFont = UIFont.preferredFont(forTextStyle: .caption1)
    
    let h1: UIFont = UIFont.preferredFont(forTextStyle: .title1)
    
    let h2: UIFont = UIFont.preferredFont(forTextStyle: .title2)
    
    let caption2: UIFont = UIFont.preferredFont(forTextStyle: .caption2)
}
