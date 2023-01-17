//
//  BookCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/12/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class LibraryCell: UICollectionViewCell {
    

    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var readProgressView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var book : Comic? {
        didSet{
            guard let imageName = book?.thumbnailNames?.firstObject as? String else { return }
            let cover = ComicImage(book, withImageName: imageName)
            coverImageView.image = UIImage(contentsOfFile: cover.path)
            if let name = book?.name {
                nameLabel.text = name
            }
            updateProgressValue()
        }
    }
    
    var isInEditingMode: Bool = false {
        didSet{
            selectionImageView.isHidden = !isInEditingMode
            if book?.lastVisitedPage != 0 {
                readProgressView.isHidden = isInEditingMode
            }
        }
    }
    
    
    override var isSelected: Bool {
        didSet{
            if !isInEditingMode { return }
            UIView.animate(withDuration: 0.2) {
                self.whiteView.alpha = self.isSelected ? 0.6 : 0
            }
            selectionImageView.image = isSelected ?  #imageLiteral(resourceName: "ic-actions-selected").withTintColor(.white) : #imageLiteral(resourceName: "ic-actions-select").withTintColor(.white)
        }
    }
    
    var showNameLabel: Bool = true {
        didSet {
        nameLabel.isHidden = !showNameLabel
        }
    }
    
    func setUpDesign(){
        selectionImageView.image = #imageLiteral(resourceName: "ic-actions-select").withTintColor(.white)
        readProgressView.strokeWidth = 2
        coverImageView.layer.cornerRadius = 4
        coverImageView.clipsToBounds = true
        whiteView.layer.cornerRadius = 4
        whiteView.clipsToBounds = true
        self.clipsToBounds = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpDesign()
        updateProgressValue()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readProgressView.progressCircleColor = UIColor.appMainColor.cgColor
        shadowView.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 5)
    }
    
    
    func updateProgressValue(){
        
        if let lastPage = book?.lastVisitedPage,
        let totalPages = book?.imageNames?.count,
            lastPage != 0,
        totalPages > 1 {
            let value: Double = Double(lastPage - 1) / Double(totalPages - 1)
            readProgressView.progressValue = CGFloat(value)
            readProgressView.isHidden = isInEditingMode
        }
        if let lastPage = book?.lastVisitedPage,
            lastPage == 0 {
            readProgressView.isHidden = true
        }
        
    }
    
    
    
    
}
