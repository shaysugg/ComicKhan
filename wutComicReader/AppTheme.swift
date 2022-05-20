//
//  ReaderTheme.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/24/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

struct AppTheme: Hashable {
    let id: String
    let primaryColor: UIColor
    let backgroundColor: UIColor
    let labelColor: UIColor
}

extension AppTheme {
    
    static let themes: [AppTheme] = [.light, .dark, .yellow]
    
    static func theme(byID id: String) -> AppTheme? {
        return themes.first { $0.id == id }
    }
    
    static let light = AppTheme(
        id: "light",
        primaryColor: .white,
        backgroundColor: .lightGray,
        labelColor: .black)
    
    static let dark = AppTheme(
        id: "dark",
        primaryColor: .white,
        backgroundColor: .lightGray,
        labelColor: .black)
    
    
    static let yellow = AppTheme(
        id: "yellow",
        primaryColor: .yellow,
        backgroundColor: .lightGray,
        labelColor: .black)
    
    
}
