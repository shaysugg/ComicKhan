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
        fetchResultController.sections?[section].objects?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectioViewIDs.comicCell.id, for: indexPath) as! LibraryCell
        cell.isInEditingMode = editingMode
        cell.book = fetchResultController.object(at: indexPath)
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchResultController.sections?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectioViewIDs.comicGroupHeader.id, for: indexPath) as! LibraryReusableView
        
        header.headerLabel.text = fetchResultController.sections?[indexPath.section].name
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let comic = fetchResultController.sections?[section].objects?.first as! Comic
        let isGroupForNewComics = comic.ofComicGroup?.isForNewComics ?? false
        
        if isGroupForNewComics {
            return CGSize(width: collectionView.bounds.width, height: 10)
        }else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedComic = fetchResultController.object(at: indexPath)

        if editingMode {
            indexSelectionManager.insert(indexPath)
            
        }else{
            
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            
            var readerVCFactory = BookReaderFactory(comic: selectedComic)
            readerVCFactory.loadingHandler = { [weak self] in
                self?.addLoadingView()
            }
            
            readerVCFactory.comicReadingProgressDidChanged = {[weak self] comic , lastPage in
                guard let self = self else { return }
                guard let index = self.fetchResultController.indexPath(forObject: comic) else { return }
                try? self.dataService.saveLastPageOf(comic: comic, lastPage: lastPage)
                self.bookCollectionView.reloadItems(at: [index])
            }
            
            readerVCFactory.build { [weak self] readerVC in
                self?.present(readerVC, animated: true, completion: { [weak self] in

                    self?.removeLoadingView()
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if editingMode{
            indexSelectionManager.remove(indexPath)
        }
    }
    
    //MARK:- Cell Animations
    
    
    fileprivate func addLoadingView() {
        
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.tag = 110
        loadingView.isHidden = false
        
        bookCollectionView.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    fileprivate func removeLoadingView() {
        let view = bookCollectionView.viewWithTag(110)
        view?.isHidden = true
        view?.removeFromSuperview()
    }
    
}
