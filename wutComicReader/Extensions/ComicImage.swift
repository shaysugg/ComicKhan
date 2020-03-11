//
//  ComicImage.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/11/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit

class ComicImage: UIImage {
    //page number starts from 1
    var pageNumber: Int?
    var isDoubleSplash = false
    
    convenience init?(_ comic: Comic? ,withImageName imageName: String?) {
        let comicname : String = comic?.name ?? ""
        let imagename: String = imageName ?? ""
        let appfileManager = AppFileManager()
        
        let path = appfileManager.comicDirectory.path + "/" + comicname  + "/" + imagename
        
        self.init(contentsOfFile: path)
        
        if let imageSize = UIImage(contentsOfFile: path)?.size {
            isDoubleSplash = imageSize.width > imageSize.height
        }
        
    }
}
