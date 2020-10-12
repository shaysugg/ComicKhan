//
//  +NSLayoutContraint.swift
//  wutComicReader
//
//  Created by Sha Yan on 10/12/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func withHighPiority() -> NSLayoutConstraint {
        let piority = UILayoutPriority(850)
        self.priority = piority
        return self
    }
    
    func withLowPiority() -> NSLayoutConstraint {
        let piority = UILayoutPriority(250)
        self.priority = piority
        return self
    }
}
