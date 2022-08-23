//
//  ReaderBottomBar.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/27/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit

protocol BottomBarDelegate: AnyObject {
    func newPageBeenSet(pageNumber: Int)
    func settingTapped()
//    func pageModeChanged(to pageMode: BookReaderPageMode)
}

final class BottomBar: UIView {
    
    weak var thumbnailsDataSource: UICollectionViewDataSource? {
        didSet{
            thumbnailCollectionView.dataSource = thumbnailsDataSource
            
        }
    }
    
    weak var thumbnailDelegate: UICollectionViewDelegate? {
        didSet {
            thumbnailCollectionView.delegate = thumbnailDelegate
        }
    }
    
    weak var delegate: BottomBarDelegate?
    
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
    
    lazy var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
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
        slider.tintColor = .appMainColor
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.minimumTrackTintColor = .appMainColor
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
        label.font = AppState.main.font.caption
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        return label
    }()
    
    private lazy var comicPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = AppState.main.font.caption
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "50"
        return label
    }()
    
    private lazy var sliderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var settingButton: UIButton = {
        let view = UIButton()
        let image = UIImage(named: "ic-actions-more-1")?.withTintColor(.appMainLabelColor)
        view.setImage(image, for: .normal)
        view.layer.borderColor = UIColor.appMainLabelColor.cgColor
        view.addAction(settingDidTapped(), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDesign()
    }
    
    private func setUpDesign(){
        
        backgroundColor = .appBackground
        
        addSubview(settingButton)
        settingButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        settingButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        addSubview(sliderStackView)
        sliderStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        sliderStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        sliderStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
        sliderStackView.addArrangedSubview(currentPageNumberLabel)
        sliderStackView.addArrangedSubview(pageSlider)
        sliderStackView.addArrangedSubview(comicPageNumberLabel)

        addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: settingButton.bottomAnchor, constant: 5).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: sliderStackView.topAnchor, constant: -5).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
   
    }
    
//    private func configurePageModeMenu() {
//        let singleMode =
//        UIAction(title: NSLocalizedString("Single page", comment: ""),
//                 image: UIImage(named: "single-page")?.withTintColor(.appMainLabelColor)) { [weak self] action in
//            self?.delegate?.pageModeChanged(to: .single)
//        }
//
//        let doubleMode =
//        UIAction(title: NSLocalizedString("Two pages", comment: ""),
//                 image: UIImage(named: "two-pages")?.withTintColor(.appMainLabelColor) ) { [weak self] action in
//            self?.delegate?.pageModeChanged(to: .double)
//        }
//
//
//        let menu = UIMenu(title: "Reader Setting", options: .displayInline, children:  [singleMode, doubleMode])
//
//        settingButton.menu = menu
//        settingButton.showsMenuAsPrimaryAction = true
//    }
    
    private func settingDidTapped() -> UIAction {
        UIAction { [weak self] _ in
            self?.delegate?.settingTapped()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20
        makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.5, radius: 10)
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
    
    func invalidateThimbnailCollectionViewLayout() {
        thumbnailCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}
