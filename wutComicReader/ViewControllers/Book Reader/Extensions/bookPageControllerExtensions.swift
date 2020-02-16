//
//  bookPageControllerExtensions.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/24/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

//MARK:- book Pages Setup

extension BookReaderVC {
    
    
    func setupPageController() {
        bookPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        bookPageViewController.delegate = self
        bookPageViewController.dataSource = self
        
        addChild(bookPageViewController)
        view.addSubview(bookPageViewController.view)
        
        createSingleBookImages()
        createDoubleBookImages()
        setPageViewControllers()
    }
    
    
    fileprivate func createSingleBookImages() {
        //bookSinglePage Setup
        guard let comicPages = comic?.imageNames else { return }
        for comicPage in comicPages {
            let bookPageImage = ComicImage(comic, withImageName: comicPage) ?? ComicImage()
            bookPageImage.pageNumber = comicPages.firstIndex(of: comicPage)
            bookSingleImages.append(bookPageImage)
        }
        
    }
    
    fileprivate func createDoubleBookImages(){
        
        var tempDouble: [ComicImage?] = [nil]
        guard let comicPages = comic?.imageNames else { return }
        
        //creating tempDoubles
        
        for comicPage in comicPages {
            let index = comicPages.firstIndex(of: comicPage)!
            let image = ComicImage(comic, withImageName: comicPage) ?? ComicImage()
            image.pageNumber = comicPages.firstIndex(of: comicPage)
            
            if isImageInDoubleSplashSize(image) {
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
                        bookDoubleImages.append((tempDouble[index], tempDouble[index + 1]))
                    }
                }else{
                    bookDoubleImages.append((tempDouble[index] , nil))
                }
            }
        }
        
    }
    
    
    fileprivate func isImageInDoubleSplashSize(_ image: UIImage) -> Bool {
        return image.size.height < image.size.width
    }
    
    
    func setPageViewControllers() {
        
        bookPages.removeAll()
        
        if deviceIsLandscaped {
            for bookImages in bookDoubleImages {
                let bookPage = BookPage()
                
                bookPage.pageNumber = bookDoubleImages.firstIndex(where: { $0 == bookImages })
                bookPage.pageImageView1.image = bookImages.0
                bookPage.pageImageView2.image = bookImages.1
                
                bookPages.append(bookPage)
            }
        }else{
            for bookImage in bookSingleImages {
                let bookPage = BookPage()
                bookPage.pageNumber = bookSingleImages.firstIndex(where: { $0 == bookImage })
                bookPage.pageImageView1.image = bookImage
                
                bookPages.append(bookPage)
            }
        }
        
        bookPageViewController.setViewControllers([bookPages[0]], direction: .forward, animated: false)

    }
    
    func doublePageIndexForPage(withNumber pageNumber:Int) -> Int? {
        if pageNumber < bookSingleImages.count {
            let number = bookSingleImages[pageNumber].pageNumber
            
            return bookDoubleImages.firstIndex { touple -> Bool in
                return (touple.0?.pageNumber == number || touple.1?.pageNumber == number)
            }
            
        }
        return nil
    }
    
}

//MARK:- book Pages Delegates

extension BookReaderVC : UIPageViewControllerDataSource , UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController:
        UIViewController) -> UIViewController? {
        
        
        
        if let index = bookPages.firstIndex(of: viewController as! BookPage) {
            if index < bookPages.count - 1 {
                return bookPages[index + 1]
            }else{
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = bookPages.firstIndex(of: viewController as! BookPage) {
            if index > 0 {
                return bookPages[index - 1]
            }else {
                return nil
            }
        }
        return nil
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //zoom out precious pages
        guard let previousPages = pageViewController.viewControllers as? [BookPage] else { return }
        for page in previousPages {
            page.scrollView.setZoomScale(page.scrollView.minimumZoomScale, animated: false)
        }
        guard let pendingPages = (pendingViewControllers as? [BookPage]) else { return }
        setLastViewedPageNumber(for: pendingPages[0])
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            guard let previousPages = pageViewController.viewControllers as? [BookPage] else { return }
            for page in previousPages {
                let _ = bookPages.firstIndex(of: previousPages[0])
                page.scrollView.setZoomScale(page.scrollView.minimumZoomScale, animated: false)
            }
            
            
            
            //update thumbnail and slider
            
            guard let pendingPage = pageViewController.viewControllers?[0] as? BookPage else { return }
            guard let pendingIndex = bookPages.firstIndex(of: pendingPage) else { return }
            thumbnailCollectionView.selectItem(at: IndexPath(row: pendingIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            
            pageSlider.setValue(Float(pendingIndex + 1), animated: true)
            currentPageNumberLabel.text = String (pendingIndex + 1)
            
            
        }

    }
    
    
    
    
}
