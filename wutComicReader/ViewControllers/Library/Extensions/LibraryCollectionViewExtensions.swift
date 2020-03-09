//
//  LibraryCollectionViewExtensions.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/2/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit


extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comicGroups[section].comics?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! LibraryCell
        cell.isInEditingMode = editingMode
        cell.book = comicGroups[indexPath.section].comics?[indexPath.row] as? Comic
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comicGroups.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath) as! LibraryReusableView
        header.headerLabel.text = comicGroups[indexPath.section].name
        header.isEditing = editingMode
        header.indexSet = indexPath.section
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedComic = comicGroups[indexPath.section].comics?[indexPath.row] as! Comic
        let selectedCell = collectionView.cellForItem(at: indexPath)!
        
        if editingMode {
            if !selectedComics.contains(selectedComic) {
                selectedComics.append(selectedComic)
                
            }
        }else{
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
            readerVC.comic = selectedComic
            readerVC.bookIndexInLibrary = indexPath
            readerVC.modalPresentationStyle = .fullScreen
            present(readerVC, animated: true)
//            cellFullSizeView.image = ComicImage(selectedComic, withImageName: selectedComic.imageNames?.first)
////            cellFullSizeView.backgroundColor = .black
//            addOveralyView(withFrame: selectedCell.frame, complition: { [weak self] in
//                self?.present(readerVC , animated: false)
////                self?.removeCellFullSizeImage()
//            })
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if editingMode{
            
            let deSelectedComic = comicGroups[indexPath.section].comics?[indexPath.row] as! Comic
            
            if selectedComics.contains(deSelectedComic){
                guard let comic = selectedComics.firstIndex(of: deSelectedComic) else { return }
                selectedComics.remove(at: comic)
            }
        }
    }
    
    //MARK:- Cell Animations
    
    fileprivate func addOveralyView(withFrame frame:CGRect, complition: @escaping ()->()) {
        
        bookCollectionView.addSubview(cellFullSizeView)
        cellFullSizeView.frame = CGRect(x: frame.minX, y: frame.minY, width: collectionViewCellSize.width , height: collectionViewCellSize.height)
        
        cellFullSizeConstraint = [
            cellFullSizeView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,constant: 0),
             cellFullSizeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 0),
             cellFullSizeView.widthAnchor.constraint(equalToConstant: bookCollectionView.bounds.width),
             cellFullSizeView.heightAnchor.constraint(equalToConstant: bookCollectionView.bounds.height)
        ]
        
        NSLayoutConstraint.activate(cellFullSizeConstraint)
        
        cellFullSizeView.layer.cornerRadius = 4
        
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.bookCollectionView.layoutIfNeeded()
            self.cellFullSizeView.layer.cornerRadius = 0
        }) { (_) in
            complition()
        }
        
    }
    
    fileprivate func  removeCellFullSizeImage() {
        cellFullSizeView.removeFromSuperview()
        NSLayoutConstraint.deactivate(cellFullSizeConstraint)
        cellFullSizeConstraint.removeAll()
    }
    
}
