//
//  thumbnailCollectionViewExtensions.swift
//  wutComicReader
//
//  Created by Sha Yan on 1/24/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

extension BookReaderVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceIsLandscaped ? bookDoubleImages.count : bookSingleImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! thumbnailCell
        
        let resizeSize = resizeSizeforImage(InIndexPath: indexPath, inLandscpeMode: deviceIsLandscaped)
        
        if deviceIsLandscaped{
            cell.pageNumber = indexPath.row * 2 - 1
            cell.pageImageView1.image = bookDoubleImages[indexPath.row].0?.resize(forSize: resizeSize)
            cell.pageImageView2.image = bookDoubleImages[indexPath.row].1?.resize(forSize: resizeSize)
            
        }else {
            cell.pageImageView1.image  = bookSingleImages[indexPath.row].resize(forSize: resizeSize)
            cell.pageNumber = indexPath.row + 1
        }
        cell.haveDoublePage = deviceIsLandscaped
        cell.isDoubleSplashPage = resizeSize.width > resizeSize.height
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * (deviceIsLandscaped ? 1.22 : 0.58), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        thumbnailCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        bookPageViewController.setViewControllers([bookPages[indexPath.row]], direction: .forward, animated: true, completion: nil)
        
        updatePageSlider(with: indexPath.row + 1)
        setLastViewedPageNumber(for: bookPages[indexPath.row])
    }
    
    
    
    fileprivate func isImageInDoubleSplashSize(_ image: UIImage) -> Bool {
        return image.size.height < image.size.width
    }
    
    fileprivate func resizeSizeforImage(InIndexPath indexPath: IndexPath, inLandscpeMode isLandscape: Bool) -> CGSize {
        if isLandscape {
            let pageIsDoubleSplash = isImageInDoubleSplashSize(bookDoubleImages[indexPath.row].0 ?? UIImage()) ||
                                     isImageInDoubleSplashSize(bookDoubleImages[indexPath.row].1 ?? UIImage())
            return CGSize(width: 87 * (pageIsDoubleSplash ? 2 : 1), height: 150)
            
        }else{
            let pageIsDoubleSplash = isImageInDoubleSplashSize(bookSingleImages[indexPath.row])
            return CGSize(width: 87 * (pageIsDoubleSplash ? 2 : 1) , height: 150)
        }
    }
}
