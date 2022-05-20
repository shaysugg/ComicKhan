//
//  ThemesStackView.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/26/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import UIKit

class ThemesStackView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ThemesStackViewItem.self, forCellWithReuseIdentifier: ThemesStackViewItem.id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
}


fileprivate class ThemesStackViewItem: UICollectionViewCell {
    
    let theme: AppTheme
    let onSelected: (AppTheme) -> Void
    
    init(theme: AppTheme, onSelected: @escaping (AppTheme) -> Void) {
        self.theme = theme
        self.onSelected = onSelected
        super.init(frame: .zero)
        setupDesign()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSelected))
        addGestureRecognizer(gestureRecognizer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAsSelected(_ selected: Bool) {
        alpha = selected ? 1 : 0.5
    }
    
    private func setupDesign() {
        backgroundColor = theme.primaryColor
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width * 0.5
    }
    
    @objc
    private func didSelected() {
        onSelected(theme)
    }
    
}
