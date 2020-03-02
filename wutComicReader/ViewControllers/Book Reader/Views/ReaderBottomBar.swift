//
//  ReaderBottomBar.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/27/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit


class BottomBar: UIView {
    
    var thumbnailDelegate: BookReaderVC? {
        didSet{
            thumbnailCollectionView.delegate = thumbnailDelegate
            thumbnailCollectionView.dataSource = thumbnailDelegate
        }
    }
    var delegate: BottomBarDelegate?
    
    var currentPage: Int? {
        didSet{
            guard let page = currentPage,
                0 < page && page <= comicPagesCount else { return }
            
            thumbnailCollectionView.selectItem(at: IndexPath(row: page - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            pageSlider.setValue(Float(page), animated: true)
            currentPageNumberLabel.text = String(page)
        }
    }
    
    var comicPagesCount: Int = 1 {
        didSet{
            comicPageNumberLabel.text = String(comicPagesCount)
            pageSlider.maximumValue = Float(comicPagesCount)
        }
    }
    
    private lazy var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        collectionView.restorationIdentifier = "thumbnail"
        collectionView.backgroundColor = UIColor.white.withAlphaComponent(0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.clipsToBounds = true
        return collectionView
    }()
    
    private lazy var pageSlider : UISlider = {
        let slider = UISlider(frame: .zero)
        slider.tintColor = .appBlueColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.minimumTrackTintColor = .appBlueColor
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.setValue(1.00, animated: false)
        slider.addTarget(self, action: #selector(sliderDidChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchCancel)
        return slider
    }()
    
    private lazy var currentPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: HelvetincaNeueFont.thin.name, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        return label
    }()
    
    private lazy var comicPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: HelvetincaNeueFont.thin.name, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "50"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDesign()
    }
    
    private func setUpDesign(){
        
        backgroundColor = .appSystemBackground
        
        addSubview(pageSlider)
        pageSlider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.62).isActive = true
        pageSlider.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageSlider.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
        addSubview(currentPageNumberLabel)
        currentPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor).isActive = true
        currentPageNumberLabel.rightAnchor.constraint(equalTo: pageSlider.leftAnchor, constant: -17).isActive = true
        
        addSubview(comicPageNumberLabel)
        comicPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor).isActive = true
        comicPageNumberLabel.leftAnchor.constraint(equalTo: pageSlider.rightAnchor, constant: 17).isActive = true
        
        addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: pageSlider.topAnchor, constant: -5).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = 20
        makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.5, radius: 15)
    }
    
    @objc private func sliderDidChanged(){
           let value = Int(pageSlider.value)
           
           thumbnailCollectionView.scrollToItem(at: IndexPath(row: value - 1, section: 0), at: .centeredHorizontally, animated: false)
        currentPageNumberLabel.text = String(value)
        
       }
    
    @objc private func sliderDidFinishedChanging(){
        let value = Int(pageSlider.value)
        delegate?.newPageBeenSet(pageNumber: value)
        
        
        thumbnailCollectionView.selectItem(at: IndexPath(row: value - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        currentPageNumberLabel.text = String(value)
        delegate?.newPageBeenSet(pageNumber: value)
    }
    
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    
}
