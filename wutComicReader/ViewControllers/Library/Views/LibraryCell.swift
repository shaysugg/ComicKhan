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
            #warning("line below would crash if comic has no pages!")
            guard let imageName = book?.imageNames?.first else { return }
            
            let cover = ComicImage(book, withImageName: imageName)
            bookCoverImageView.image = imageResizer.resize(UIImage(contentsOfFile: cover.path) ,
                                                           to: CGSize(width: 300, height: 450))
            updateProgressValue()
        }
    }
    
    var isInEditingMode: Bool = false {
        didSet{
            selectionImageView.isHidden = !isInEditingMode
            readProgressView.isHidden = isInEditingMode
        }
    }
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var readProgressView: CircleProgressView!
    
    
    override var isSelected: Bool {
        didSet{
            whiteView.alpha = isSelected ? 0.6 : 0
            selectionImageView.image = isSelected ? #imageLiteral(resourceName: "Mask Copy") : #imageLiteral(resourceName: "selected")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpDesign(){
        
        self.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 15)
        selectionImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 5)
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
        readProgressView.progressCircleColor = UIColor.appBlueColor?.cgColor
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
