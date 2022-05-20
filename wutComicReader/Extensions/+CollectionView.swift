//
//  +CollectionView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/27/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    static var id: String {
        NSStringFromClass(self)
    }
}

extension UITableViewCell {
    static var id: String {
        NSStringFromClass(self)
    }
}
