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
        return comicPagesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! thumbnailCell
        cell.comicPage1  = UIImage(comic, withImageName: comic?.imageNames?[indexPath.row])
        cell.pageNumber = indexPath.row + 1
        cell.isDoupleSplashPage = isImageInDoubleSplashSize(image: cell.comicPage1!)
        cell.haveDoublePage = deviceIsLandscaped
        
        
        if deviceIsLandscaped{
            cell.comicPage1  = UIImage(comic, withImageName: comic?.imageNames?[indexPath.row * 2])
            cell.pageNumber = indexPath.row * 2 - 1
            if indexPath.row * 2 + 1 < comic!.imageNames!.count {
                cell.comicPage2 = UIImage(comic, withImageName: comic?.imageNames?[indexPath.row * 2 + 1])
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * (deviceIsLandscaped ? 1.22 : 0.58), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        thumbnailCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        bookPageViewController.setViewControllers([bookPages[indexPath.row]], direction: .forward, animated: true, completion: nil)
        updatePageSlider(with: indexPath.row + 1)
    }
    
    
}
