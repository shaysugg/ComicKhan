//
//  Library+FetchResultController.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import CoreData

extension LibraryVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let index = newIndexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.bookCollectionView.insertItems(at: [index])
                }))
            }
        case .delete:
            if let index = indexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.bookCollectionView.deleteItems(at: [index])
                }))
            }
        case .update:
            if let updatatdComic = anObject as? Comic,
                let index = indexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    let cell = self?.bookCollectionView.cellForItem(at: index) as? LibraryCell
                    cell?.book = updatatdComic
                }))
                    
            }
        case .move:
            if let index = indexPath,
                let newIndex = newIndexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.bookCollectionView.deleteItems(at: [index])
                    self?.bookCollectionView.insertItems(at: [newIndex])
                }))
            }
        default:
            break
        }
        
        
        UIView.animate(withDuration: 0.2) {
            self.emptyGroupsView.isHidden = !(controller.fetchedObjects?.isEmpty ?? true)
        }
        
        
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(arrayLiteral: sectionIndex)
        
        switch type {
        case .insert:
            
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.bookCollectionView.insertSections(indexSet)
                }))
            
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.bookCollectionView.deleteSections(indexSet)
            }))
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.bookCollectionView.reloadData()
            }))
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.bookCollectionView.reloadSections(indexSet)
            }))
            
        default:
            break
        }
    
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        bookCollectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }) { (_) in
            self.blockOperations.removeAll()
        }
    }
    
}
