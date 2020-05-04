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
        return fetchResultController.sections?[section].objects?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! LibraryCell
        cell.isInEditingMode = editingMode
        cell.book = fetchResultController.object(at: indexPath)
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath) as! LibraryReusableView
        let firstSectionComic = fetchResultController.sections?[indexPath.section].objects?.first as? Comic
        header.headerLabel.text = firstSectionComic?.ofComicGroup?.name 
        header.isEditing = editingMode
        header.indexSet = indexPath.section
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        let selectedComic = fetchResultController.object(at: indexPath)


        if editingMode {
            if !selectedComics.contains(selectedComic) {
                selectedComics.append(selectedComic)
                selectedComicsIndexPaths.append(indexPath)

            }
        }else{
//
            addLoadingView()
//
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
            readerVC.comic = selectedComic
            readerVC.dataService = dataService
            readerVC.bookIndexInLibrary = indexPath
            readerVC.modalPresentationStyle = .fullScreen
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                readerVC.createSingleBookImages()
                readerVC.createDoubleBookImages()
                readerVC.initSinglePageThumbnails()
                
                DispatchQueue.main.async { [weak self] in
                    self?.present(readerVC, animated: true, completion: { [weak self] in

                        self?.removeLoadingView()
                    })
                }
            }
//
            
            
           
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if editingMode{
            
            let deSelectedComic = fetchResultController.object(at: indexPath) as! Comic
            let deSelectedIndex = selectedComicsIndexPaths.firstIndex(of: indexPath)
            
            if selectedComics.contains(deSelectedComic), let _ = deSelectedIndex {
                guard let comic = selectedComics.firstIndex(of: deSelectedComic) else { return }
                selectedComics.remove(at: comic)
                selectedComicsIndexPaths.remove(at: deSelectedIndex!)
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
    
    fileprivate func addLoadingView() {
        
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.tag = 110
        loadingView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.bookCollectionView.addSubview(loadingView)
            loadingView.centerXAnchor.constraint(equalTo: self.bookCollectionView.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: self.bookCollectionView.centerYAnchor).isActive = true
            loadingView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            loadingView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        
        
    }
    
    fileprivate func removeLoadingView() {
        let view = bookCollectionView.viewWithTag(110)
        view?.isHidden = true
        view?.removeFromSuperview()
    }
    
}
