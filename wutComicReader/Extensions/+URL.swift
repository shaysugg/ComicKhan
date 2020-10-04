//
//  +URL.swift
//  wutComicReader
//
//  Created by Sha Yan on 10/3/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation

fileprivate var comicDiractoryName = "ComicFiles"

extension URL {
    static var comicDiractory: URL {
       return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(comicDiractoryName)
    }
    static var userDiractory: URL {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func fileName() -> String {
        return self.deletingPathExtension().lastPathComponent
    }
}
