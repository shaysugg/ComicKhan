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
            
            readerVC.bookSingleImages = createSingleBookImages()
            readerVC.bookDoubleImages = createDoubleBookImages()
            readerVC.thumbnailImages = initSinglePageThumbnails()
            
            
            DispatchQueue.main.async {
                complition(readerVC)
            }
        }
    }
    
}


fileprivate extension BookReaderFactory {
    
    private func createSingleBookImages() -> [ComicImage] {
        guard let comicPages = comic.imageNames as? [String] else { return [] }
        return comicPages.map { (comicPage) -> ComicImage in
            var bookPageImage = ComicImage(comic, withImageName: comicPage)
            bookPageImage.pageNumber = comicPages.firstIndex(of: comicPage)! + 1
            return bookPageImage
        }
        
    }
    
    private func createDoubleBookImages() -> [(ComicImage?, ComicImage?)]{
        
        var tempDouble: [ComicImage?] = [nil]
        guard let comicPages = comic.imageNames as? [String] else { return [] }
        var comicImages = [(ComicImage?, ComicImage?)]()
        
        
        func isImageInDoubleSplashSize(_ image: UIImage) -> Bool {
            return image.size.height < image.size.width
        }
        
        //creating tempDoubles
        
        for comicPage in comicPages {
            let index = comicPages.firstIndex(of: comicPage)!
            var image = ComicImage(comic, withImageName: comicPage)
            image.pageNumber = comicPages.firstIndex(of: comicPage)! + 1
            
            if isImageInDoubleSplashSize(UIImage(contentsOfFile: image.path) ?? UIImage()) {
                if index.isMultiple(of: 2) {
                    tempDouble.append(contentsOf: [nil , image , nil])
                }else{
                    tempDouble.append(contentsOf: [image , nil])
                }
            }else{
                tempDouble.append(image)
            }
        }
        
        //creating doubleImages
        
        for index in 0 ... tempDouble.count - 1 {
            if index.isMultiple(of: 2){
                if index < tempDouble.count - 1 {
                    if tempDouble[index] == nil && tempDouble[index + 1] == nil {} else {
                        comicImages.append((tempDouble[index], tempDouble[index + 1]))
                    }
                }else{
                    comicImages.append((tempDouble[index] , nil))
                }
            }
        }
        
        return comicImages
        
    }
    
    func initSinglePageThumbnails() -> [ComicImage]{
        guard let thumbnails = comic.thumbnailNames as? [String] else { return [] }
        var pageNumber = 1
        return thumbnails.map { thumbnail -> ComicImage in
            var comicImage = ComicImage(comic, withImageName: thumbnail)
            comicImage.pageNumber = pageNumber
            pageNumber += 1
            return comicImage
        }
    }
    
}
