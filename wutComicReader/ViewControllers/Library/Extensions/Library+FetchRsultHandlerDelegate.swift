//
//  Library+FetchRsultHandlerDelegate.swift
//  wutComicReader
//
//  Created by Sha Yan on 3/6/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import UIKit

extension LibraryVC: LibraryFetchResultControllerHandlerDelegate {
    func libraryBecame(empty: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.emptyGroupsView.alpha = empty ? 1 : 0
            self?.bookCollectionView.alpha = empty ? 0 : 1
        } completion: { [weak self] _ in
            self?.emptyGroupsView.isHidden = !empty
            self?.bookCollectionView.isHidden = empty
        }   
    }
}
