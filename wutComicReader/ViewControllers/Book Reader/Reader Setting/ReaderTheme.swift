//
//  ReaderTheme.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/24/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

enum ReaderTheme: String, CaseIterable {
    case dynamic = "dynamic"
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    
    var name: String {
        self.rawValue.capitalized
    }
}
