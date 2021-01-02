//
//  IndexSelectionManager.swift
//  wutComicReader
//
//  Created by Sha Yan on 11/21/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import Combine

class IndexSelectionManager {
    public var publisher: AnyPublisher<Set<IndexPath>,Never>!
    public var indexes: Set<IndexPath> { _indexes }
    @Published private var _indexes = Set<IndexPath>()
    @Published var lastIndexThatChanged: IndexPath?
    
    var cancellable: AnyCancellable?
    init() {
        publisher = $_indexes.eraseToAnyPublisher()
        
        cancellable = $_indexes.sink { (set) in
            print("✅ Selected Comics -> ", set)
        }
    }
    
    func insert(_ index: IndexPath) {
        _indexes.insert(index)
        lastIndexThatChanged = index
    }
    
    func remove(_ index:IndexPath) {
        _indexes.remove(index)
        lastIndexThatChanged = index
    }
    
    func removeAll() {
        _indexes.removeAll()
    }
    
    func isSelectedAllItemsOf(collectionView: UICollectionView, inSection section: Int) -> Bool {
        _indexes.filter{$0.section == section}.count == collectionView.numberOfItems(inSection: section)
    }
}
