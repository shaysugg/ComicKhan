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
        return deviceIsLandscaped ? thumbnailDoublePageViewModels.count : thumbnailSinglePageViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! thumbnailCell
        
        let resizeSize = resizeSizeforImage(InIndexPath: indexPath, inLandscpeMode: deviceIsLandscaped)
        
        if deviceIsLandscaped{
            cell.thumbnailViewModel = thumbnailDoublePageViewModels[indexPath.row]
            
        }else {
            cell.thumbnailViewModel = thumbnailSinglePageViewModels[indexPath.row]
        }
//        cell.haveDoublePage = deviceIsLandscaped
//        cell.isDoubleSplashPage = resizeSize.width > resizeSize.height
        
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

class ThumbnailViewModel {
    let haveDoublePage: Bool
    var image1: UIImage?
    var image2: UIImage?
    var imagesIsDoubleSplash: (Bool, Bool) = (false,false)
    
    init(haveDoublePage: Bool, image1: ComicImage?, image2: ComicImage?) {
        self.haveDoublePage = haveDoublePage
        self.image1 = image1
        self.image2 = image2
        self.imagesIsDoubleSplash = (isImageInDoubleSplashSize(image1), isImageInDoubleSplashSize(image2))
        
        let resizeSize = resizeSizeforImages()
        self.image1 = image1?.resize(forSize: resizeSize)
        self.image2 = image2?.resize(forSize: resizeSize)
    }
    
    private func resizeSizeforImages() -> CGSize {
        if haveDoublePage {
            let pageIsDoubleSplash = isImageInDoubleSplashSize(image1 ?? UIImage()) ||
                isImageInDoubleSplashSize(image2 ?? UIImage())
            return CGSize(width: 87 * (pageIsDoubleSplash ? 2 : 1), height: 150)
        }else{
            let pageIsDoubleSplash = isImageInDoubleSplashSize(image1 ?? UIImage())
            return CGSize(width: 87 * (pageIsDoubleSplash ? 2 : 1) , height: 150)
        }
    }
    
    private func isImageInDoubleSplashSize(_ image: UIImage?) -> Bool {
        guard let img = image else { return false }
        return img.size.height < img.size.width
    }
    
}


extension BookReaderVC {
    func initDoublePageThumbnails(){
        for images in bookDoubleImages {
            let newThumbnail = ThumbnailViewModel(haveDoublePage: true, image1: images.0, image2: images.1)
            thumbnailDoublePageViewModels.append(newThumbnail)
        }
    }
    
    func initSinglePageThumbnails(){
        for image in bookSingleImages {
            let newThumbnail = ThumbnailViewModel(haveDoublePage: false, image1: image, image2: nil)
            thumbnailSinglePageViewModels.append(newThumbnail)
        }
    }
}
