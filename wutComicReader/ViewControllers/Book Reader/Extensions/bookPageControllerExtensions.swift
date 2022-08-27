//
//  bookPageControllerExtensions.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/24/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

//MARK: book Pages Setup

extension BookReaderVC {
    
    
    func setupPageController(pageMode: ReaderPageMode) {
        bookPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        bookPageViewController.delegate = self
        bookPageViewController.dataSource = self
        
        addChild(bookPageViewController)
        view.addSubview(bookPageViewController.view)
        
        configureBookPages(pageMode: pageMode)
    }
    
    
    func configureBookPages(pageMode: ReaderPageMode) {
        
        bookPages.removeAll()
        
        switch pageMode {
        case .single:
            for bookImage in bookSingleImages {
                let bookPage = BookPage()
                bookPage.pageNumber = bookSingleImages.firstIndex(where: { $0 == bookImage })
                bookPage.image1 = bookImage
                
                bookPages.append(bookPage)
            }
        case .double:
            for bookImages in bookDoubleImages {
                let bookPage = BookPage()
                
                bookPage.pageNumber = bookDoubleImages.firstIndex(where: { $0 == bookImages })
                bookPage.image1 = bookImages.0
                bookPage.image2 = bookImages.1
                
                bookPages.append(bookPage)
            }
        }
        

    }
    
//    func doublePageIndexForPage(withNumber pageNumber:Int) -> Int? {
//        if pageNumber < bookSingleImages.count {
//            let number = bookSingleImages[pageNumber].pageNumber
//
//            return bookDoubleImages.firstIndex { touple -> Bool in
//                return (touple.0?.pageNumber == number || touple.1?.pageNumber == number)
//            }
//
//        }
//        return nil
//    }
    
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
//        setLastViewedPage(toPageWithNumber: pendingPages.first?.image1?.pageNumber ?? 0)
        
//        print("---------  started transition with view size : (\(page.view.bounds.size)")
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            let currentPage = pageViewController.viewControllers?.first as! BookPage
            if let pageNumber1 = currentPage.image1?.pageNumber{
                setLastViewedPage(toPageWithNumber: pageNumber1, withAnimate: true)
            }else if let pageNumber2 = currentPage.image2?.pageNumber {
                setLastViewedPage(toPageWithNumber: pageNumber2, withAnimate: true)
            }
            
        }

    }
    
    
    
    
}
