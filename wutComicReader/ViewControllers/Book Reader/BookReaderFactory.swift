//
//  BookReaderFactory.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/1/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import Foundation
import UIKit

struct BookReaderFactory {
    
    let comic: Comic
    let modalPresentationStyle: UIModalPresentationStyle
    var loadingHandler: (() -> Void)?
    var comicReadingProgressDidChanged: ((_ comic: Comic, _ lastPageHaveRead: Int) -> Void)?
    
    
    init(comic: Comic, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.comic = comic
        self.modalPresentationStyle = modalPresentationStyle
    }
    
    
    func build(complition: @escaping (BookReaderVC) -> Void) {
        let readerVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
        readerVC.comic = comic
        readerVC.modalPresentationStyle = modalPresentationStyle
        readerVC.comicReadingProgressDidChanged = comicReadingProgressDidChanged
        
        if (comic.imageNames?.count ?? 0) > 80 {
            loadingHandler?()
        }
        
        let dispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .userInitiated)
        dispatchQueue.async {
            
            readerVC.createSingleBookImages()
            readerVC.createDoubleBookImages()
            readerVC.initSinglePageThumbnails()
            
            DispatchQueue.main.async {
                complition(readerVC)
            }
        }
    }
}
