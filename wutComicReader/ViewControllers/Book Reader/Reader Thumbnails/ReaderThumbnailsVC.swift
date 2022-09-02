//
//  ReaderBottomBar.swift
//  wutComicReader
//
//  Created by Sha Yan on 2/27/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import Foundation
import UIKit


protocol ThumbnailVCDelegate: AnyObject {
    func newPageBeenSet(pageNumber: Int)
    func settingTapped()
}

class ReaderThumbnailVC: UINavigationController {
    
    private let vc: ThumbnailVC
    
    init(thumbnailDelegate: ThumbnailVCDelegate? = nil, thumbnailImages: [ComicImage], comicName: String) {
        vc = ThumbnailVC(thumbnailImages: thumbnailImages,
                         comicName: comicName)
        vc.delegate = thumbnailDelegate
        super.init(rootViewController: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrentPage(to page: Int, animated: Bool = true) {
        vc.setCurrentPage(to: page, animated: animated)
    }
}


fileprivate final class ThumbnailVC: UIViewController {
    
    let thumbnailImages: [ComicImage]
    let comicName: String
    
    weak var delegate: ThumbnailVCDelegate?
    
    private var currentPage: Int?
    
    var comicPagesCount: Int {
        thumbnailImages.count
    }
    
    private lazy var thumbnailCollectionView : UICollectionView = {
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
    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(thumbnailImages: [ComicImage], comicName: String) {
        self.thumbnailImages = thumbnailImages
        self.comicName = comicName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDesign()
        setupNavigationBar()
        
        comicPageNumberLabel.text = String(comicPagesCount)
        pageSlider.maximumValue = Float(comicPagesCount)
        
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
    }
    
    private func setUpDesign(){
        
        view.backgroundColor = .appBackground
        
        view.addSubview(sliderStackView)
        sliderStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        sliderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sliderStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
        sliderStackView.addArrangedSubview(currentPageNumberLabel)
        sliderStackView.addArrangedSubview(pageSlider)
        sliderStackView.addArrangedSubview(comicPageNumberLabel)

        view.addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: sliderStackView.topAnchor, constant: -5).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = comicName.capitalized
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                image: UIImage(named: "setting"),
                style: .plain,
                target: self,
                action: #selector(settingDidTapped)),
            animated: false)
        
        navigationController?.navigationBar.tintColor = .appMainLabelColor
    }
    
    @objc private func settingDidTapped() {
        delegate?.settingTapped()
    }
    
    func setCurrentPage(to page: Int, animated: Bool = true) {
        guard currentPage != page,
              (1...comicPagesCount).contains(page)
        else { return }
        currentPage = page
        
        thumbnailCollectionView.selectItem(at: IndexPath(row: page - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        pageSlider.setValue(Float(page), animated: animated)
        currentPageNumberLabel.text = String(page)
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
    
    func invalidateThimbnailCollectionViewLayout() {
        thumbnailCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}


extension ThumbnailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! ThumbnailCell
        
        cell.thumbnailImage = thumbnailImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height * (0.58), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pageNumber = thumbnailImages[indexPath.row].pageNumber else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    
        delegate?.newPageBeenSet(pageNumber: pageNumber)
        
    }
    
}
