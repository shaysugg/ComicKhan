//
//  ComicImage.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/11/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit



struct ComicImage: Equatable {
    var pageNumber: Int?
    var isDoubleSplash = false
//    var image = UIImage()
    let path: String
    
    init(_ comic: Comic?, withImageName imageName: String?) {
        let comicname : String = comic?.name ?? ""
        let imagename: String = imageName ?? ""
        
        path = URL.comicDiractory.path + "/" + comicname  + "/" + imagename
        
//        image = UIImage(contentsOfFile: path) ?? UIImage()
//        initImage()
        
        if let imageSize = UIImage(contentsOfFile: path)?.size {
            isDoubleSplash = imageSize.width > imageSize.height
        }
    }
    
}
