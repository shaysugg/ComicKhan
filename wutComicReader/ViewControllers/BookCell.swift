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
            #warning("line below would crash if comic has no pages!")
            guard let name = book?.name , let imageName = book?.imageNames?.first else { return }
            let cover = UIImage(book, withImageName: imageName)
            
            bookCoverImageView.image = cover
        }
    }
    
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    //    @IBOutlet weak var checkMarkImage: UIImageView!
    
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
    
    override func layoutSubviews() {
        self.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 15)
        selectionImageView.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 5)
    }
    
    func setUpDesign(){
        
        bookCoverImageView.layer.cornerRadius = 4
        bookCoverImageView.clipsToBounds = true
        whiteView.layer.cornerRadius = 4
        whiteView.clipsToBounds = true
        
        
        self.clipsToBounds = false
    }
    
    func fullPathofImagePath(imagePath: String){
        
    }
    
    
}
