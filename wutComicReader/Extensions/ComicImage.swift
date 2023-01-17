//
//  ComicImage.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/11/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit


//TODO: Move it to somewhere else!
struct ComicImage: Equatable {
    var pageNumber: Int?
    var isDoubleSplash = false
    let path: String
    
    init(_ comic: Comic?, withImageName imageName: String?) {
        let comicname : String = comic?.name ?? ""
        let imagename: String = imageName ?? ""
        
        path = URL.comicDiractory.appendingPathComponent(comicname).appendingPathComponent( imagename).path
        
        if let imageSize = UIImage(contentsOfFile: path)?.size {
            isDoubleSplash = imageSize.width > imageSize.height
        }
    }
    
}
