//
//  Library+FetchResultController.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import CoreData

class LibraryFetchResultControllerHandler: NSObject, NSFetchedResultsControllerDelegate {
    
    let collectionView: UICollectionView
    let fetchResultController: NSFetchedResultsController<Comic>
    private var blockOperations = [BlockOperation]()
    weak var delegate: LibraryFetchResultControllerHandlerDelegate?
    
    init(fetchResultController: NSFetchedResultsController<Comic> ,collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.fetchResultController = fetchResultController
        super.init()
        fetchResultController.delegate = self
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let index = newIndexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.insertItems(at: [index])
                }))
            }
        case .delete:
            if let index = indexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.deleteItems(at: [index])
                }))
            }
        case .update:
            if let updatatdComic = anObject as? Comic,
                let index = indexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    let cell = self?.collectionView.cellForItem(at: index) as? LibraryCell
                    cell?.book = updatatdComic
                }))
            }
        case .move:
            if let index = indexPath,
               let newIndex = newIndexPath {
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.deleteItems(at: [index])
                    self?.collectionView.insertItems(at: [newIndex])
                }))
            }
        default:
            break
        }
        
        
        delegate?.libraryBecame(empty: controller.fetchedObjects?.isEmpty ?? true)
        
        
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(arrayLiteral: sectionIndex)
        
        switch type {
        case .insert:
            
                blockOperations.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.insertSections(indexSet)
                }))
             print("------FRC Section Insert")
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.deleteSections(indexSet)
            }))
             print("------FRC Section  Delete")
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.reloadData()
            }))
            print("------FRC  Section Move")
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                self?.collectionView.reloadSections(indexSet)
            }))
            print("------FRC  Section Update")
            
        default:
            break
        }
    
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }) { (_) in
            self.blockOperations.removeAll()
        }
    }
}


protocol LibraryFetchResultControllerHandlerDelegate: NSObject {
    func libraryBecame(empty: Bool)
}
