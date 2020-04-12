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
        return thumbnailImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! ThumbnailCell
        
        cell.thumbnailImage = thumbnailImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.height * (0.58), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        setLastViewedPage(toPageWithNumber: indexPath.row + 1)
        
    }
    
}

extension BookReaderVC {
    func initSinglePageThumbnails(){
        if let thumbnails = comic?.thumbnailNames {
            var pageNumber = 1
            for thumbnail in thumbnails {
                var comicImage = ComicImage(comic, withImageName: thumbnail)
                comicImage.pageNumber = pageNumber
                pageNumber += 1
                thumbnailImages.append(comicImage)
                
            }
        }
    }
}
