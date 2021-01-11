//
//  BookCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/12/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class LibraryCell: UICollectionViewCell {
    
    var imageResizer: ImageResizer!
    
    var book : Comic? {
        didSet{
            
            guard let imageName = book?.thumbnailNames?[0] as? String else { return }
            
            let cover = ComicImage(book, withImageName: imageName)
//            bookCoverImageView.image = imageResizer.resize(UIImage(contentsOfFile: cover.path) ,
//                                                           to: CGSize(width: 300, height: 450))
            bookCoverImageView.image = UIImage(contentsOfFile: cover.path)
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
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var readProgressView: CircleProgressView!
    
    
    override var isSelected: Bool {
        didSet{
            if !isInEditingMode { return }
            UIView.animate(withDuration: 0.2) {
                self.whiteView.alpha = self.isSelected ? 0.6 : 0
            }
            selectionImageView.image = isSelected ?  #imageLiteral(resourceName: "ic-actions-selected").withTintColor(.white) : #imageLiteral(resourceName: "ic-actions-select").withTintColor(.white)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpDesign(){
        
        selectionImageView.image = #imageLiteral(resourceName: "ic-actions-select").withTintColor(.white)
        readProgressView.strokeWidth = 2
        bookCoverImageView.layer.cornerRadius = 4
        bookCoverImageView.clipsToBounds = true
        whiteView.layer.cornerRadius = 4
        whiteView.clipsToBounds = true
        self.clipsToBounds = false
    }
    
    override func awakeFromNib() {
        
        imageResizer = ImageResizer()
        setUpDesign()
        updateProgressValue()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        readProgressView.progressCircleColor = UIColor.appBlueColor.cgColor
        self.makeBoundsDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 5)
//        selectionImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 5)
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
