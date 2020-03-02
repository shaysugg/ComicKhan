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
        return bookSingleImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! ThumbnailCell
        
        cell.thumbnailViewModel = thumbnailViewModels[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let isDoubleSplash = thumbnailViewModels[indexPath.row].imagesIsDoubleSplash
        return CGSize(width: collectionView.frame.height * (isDoubleSplash ? 1.22 : 0.58), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        setLastViewedPage(toPageWithNumber: indexPath.row + 1)
        
    }
    
}

class ThumbnailViewModel {
    var image1: UIImage
    var imagesIsDoubleSplash: Bool = false
    
    init(image1: ComicImage) {
        self.imagesIsDoubleSplash = image1.size.height < image1.size.width
        let resizeSize = CGSize(width: 87 * (imagesIsDoubleSplash ? 2 : 1) , height: 150)
        self.image1 = image1.resize(forSize: resizeSize)
    }
}


extension BookReaderVC {
    func initSinglePageThumbnails(){
        for image in bookSingleImages {
            let newThumbnail = ThumbnailViewModel(image1: image)
            thumbnailViewModels.append(newThumbnail)
        }
    }
}
