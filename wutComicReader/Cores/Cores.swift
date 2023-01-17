//
//  CoresFactory.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/13/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import UIKit

final class Cores {
    static let main = Cores()
    
    let extractor: ComicExteractor
    let dataService: DataService
    let appfileManager: AppFileManager
    
    private init() {
        extractor = ComicExteractor(userDirectory: URL.userDiractory,
                                          comicDirectory: URL.comicDiractory)
        
        dataService = DataService()
        
        appfileManager = AppFileManager(dataService: dataService,
                                        userDirectory: URL.userDiractory,
                                        comicDirectory: URL.comicDiractory)
    }
}
