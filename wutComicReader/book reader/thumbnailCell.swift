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
            if isSelected {
                choosePageAsActive()
            }else{
                choosePageAsDiactive()
            }
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
    
    var imageHolderView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDesign()
    }
    
    func setupDesign() {
        
        addSubview(imageHolderView)
        imageHolderView.topAnchor.constraint(equalTo: topAnchor , constant: 10).isActive = true
        imageHolderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageHolderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageHolderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.3, radius: 25)
        
        imageHolderView.addSubview(pageImageView)
        pageImageView.topAnchor.constraint(equalTo: imageHolderView.topAnchor).isActive = true
        pageImageView.bottomAnchor.constraint(equalTo: imageHolderView.bottomAnchor , constant: -15).isActive = true
        pageImageView.leftAnchor.constraint(equalTo: imageHolderView.leftAnchor).isActive = true
        pageImageView.rightAnchor.constraint(equalTo: imageHolderView.rightAnchor).isActive = true
        
        pageImageView.clipsToBounds = true
        pageImageView.layer.cornerRadius = 2
        
        
//        addSubview(pageNumberLabel)
//        pageNumberLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        pageNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        pageNumberLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        
    }
    
    private func choosePageAsActive() {
        UIView.animate(withDuration: 0.1, animations: {
            self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: -10)
            self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.6, radius: 25)
            self.imageHolderView.alpha = 1
        }) { (_) in
            self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: -10)
            self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.6, radius: 25)
            self.imageHolderView.alpha = 1
        }
    }
    
    private func choosePageAsDiactive() {
        UIView.animate(withDuration: 0.1, animations: {
            self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.3, radius: 25)
            self.imageHolderView.alpha = 0.6
            }) { (_) in
                self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.3, radius: 25)
                self.imageHolderView.alpha = 0.6
            }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
