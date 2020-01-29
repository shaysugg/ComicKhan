//
//  bookPageControllerExtensions.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/24/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

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
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            guard let previousPages = pageViewController.viewControllers as? [BookPage] else { return }
            for page in previousPages {
                let index = bookPages.firstIndex(of: previousPages[0])
                print(index)
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
