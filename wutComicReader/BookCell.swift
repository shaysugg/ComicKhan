//
//  BookCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/12/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
    
    var book : Comic? {
        didSet{
            bookCoverImageView.image = book?.cover
            bookTitleLabel.text = book?.name
        }
    }
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    override var isSelected: Bool {
        didSet{
            bookCoverImageView.alpha = isSelected ? 0.5 : 1
            checkMarkImage.isHidden = !isSelected
        }
    }
    
    func setUpDesign(){
                shadowView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.7, radius: 25)
                bookCoverImageView.layer.cornerRadius = 2
                bookCoverImageView.clipsToBounds = true
                self.clipsToBounds = false
    }
}
