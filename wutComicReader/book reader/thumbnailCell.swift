//
//  thumbnailCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/6/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class thumbnailCell: UICollectionViewCell {
    
    var comicPage: UIImage? {
        didSet{
            pageImageView.image = comicPage
        }
    }
    var pageNumber: Int? {
        didSet{
            pageNumberLabel.text = "\(pageNumber!)"
        }
    }
    
    override var isSelected: Bool {
        didSet{
            choosePage(active: isSelected)
        }
    }
    
    var pageImageView : UIImageView = {
        let imageview = UIImageView(frame: .zero)
        imageview.contentMode = .scaleAspectFit
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    var pageNumberLabel : UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10, weight: .thin)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDesign()
    }
    
    func setupDesign() {
        addSubview(pageImageView)
        pageImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pageImageView.bottomAnchor.constraint(equalTo: bottomAnchor , constant: -15).isActive = true
        pageImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pageImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(pageNumberLabel)
        pageNumberLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        pageNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageNumberLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        
    }
    
    private func choosePage(active: Bool){
        backgroundColor = UIColor.black.withAlphaComponent( active ? 0.8 : 0)
        layer.borderWidth = active ? 2 : 0
        layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
