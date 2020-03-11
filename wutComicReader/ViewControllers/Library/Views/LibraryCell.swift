//
//  BookCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/12/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class LibraryCell: UICollectionViewCell {
    
    var book : Comic? {
        didSet{
            #warning("line below would crash if comic has no pages!")
            guard let imageName = book?.imageNames?.first else { return }
            
            let cover = ComicImage(book, withImageName: imageName)
            
            bookCoverImageView.image = cover
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
    
    lazy var readProgressView: CircleProgressView = {
        let progressView = CircleProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    
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
        
        bookCoverImageView.layer.cornerRadius = 4
        bookCoverImageView.clipsToBounds = true
        whiteView.layer.cornerRadius = 4
        whiteView.clipsToBounds = true
        self.clipsToBounds = false
    }
    
    override func awakeFromNib() {
        self.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 15)
        selectionImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 5)
        setUpDesign()
        addReadProgressView()
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
    
    private func addReadProgressView(){
        
        addSubview(readProgressView)
        readProgressView.rightAnchor.constraint(equalTo: rightAnchor, constant: 2.5).isActive = true
        readProgressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2.5).isActive = true
        readProgressView.widthAnchor.constraint(equalToConstant: bounds.width / 8).isActive = true
        readProgressView.heightAnchor.constraint(equalToConstant: bounds.width / 8).isActive = true
        
        readProgressView.makeDropShadow(shadowOffset: .zero, opacity: 0.7, radius: 1)
        
       updateProgressValue()
    }
    
    
    
    
}
