//
//  ReaderPageMode.swift
//  wutComicReader
//
//  Created by Sha Yan on 6/5/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation

enum ReaderPageMode: Int, CaseIterable {
    case single = 1
    case double = 2
    
    var name: String {
        switch self {
        case .single:
            return "Single"
        case .double:
            return "Double"
        }
    }
}
