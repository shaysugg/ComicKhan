//
//  thumbnailCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/6/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class thumbnailCell: UICollectionViewCell {

    
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
    
    var isDoubleSplashPage = false {
        didSet{
            if isDoubleSplashPage {
                checkForImageNills()
            }
        }
    }
    
    var haveDoublePage : Bool = false {
        didSet{
            
            if haveDoublePage {
                
                let widthConst = frame.width / 2
                
                imageHolderView.addSubview(pageImageView2)
                pageImageView2.topAnchor.constraint(equalTo: imageHolderView.topAnchor).isActive = true
                pageImageView2.bottomAnchor.constraint(equalTo: imageHolderView.bottomAnchor , constant: 0).isActive = true
                pageImageView2leftConstraitInDoublePageMode = pageImageView2.leftAnchor.constraint(equalTo: imageHolderView.leftAnchor , constant: widthConst)
                pageImageView2leftConstraitInDoublePageMode?.isActive = true
                pageImageView2.rightAnchor.constraint(equalTo: imageHolderView.rightAnchor).isActive = true
                pageImageView1rightConstrait?.constant = -widthConst

                
            }else{
                pageImageView2.removeFromSuperview()

                pageImageView1rightConstrait?.constant = 0
            }
            
        }
    }
    
    lazy var pageImageView1 : UIImageView = {
        let imageview = UIImageView(frame: .zero)
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    var pageImageView1rightConstraitInDoublePageMode : NSLayoutConstraint?
    var pageImageView1rightConstrait : NSLayoutConstraint?
    
    lazy var pageImageView2 : UIImageView = {
        let imageview = UIImageView(frame: .zero)
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    var pageImageView2leftConstraitInDoublePageMode : NSLayoutConstraint?
    
    
    lazy var pageNumberLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10, weight: .thin)
        label.textAlignment = .center
        return label
    }()
    
    lazy var imageHolderView : UIView = {
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
        imageHolderView.bottomAnchor.constraint(equalTo: bottomAnchor , constant: -5).isActive = true
        imageHolderView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageHolderView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageHolderView.layer.cornerRadius = 5
        imageHolderView.clipsToBounds = true
        
        imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.2, radius: 1)
        
        imageHolderView.addSubview(pageImageView1)
        pageImageView1.topAnchor.constraint(equalTo: imageHolderView.topAnchor).isActive = true
        pageImageView1.bottomAnchor.constraint(equalTo: imageHolderView.bottomAnchor , constant: 0).isActive = true
        pageImageView1.leftAnchor.constraint(equalTo: imageHolderView.leftAnchor).isActive = true
        pageImageView1rightConstrait = pageImageView1.rightAnchor.constraint(equalTo: imageHolderView.rightAnchor)
        pageImageView1rightConstrait?.isActive = true
        
//        pageImageView1rightConstraitInDoublePageMode = pageImageView1.rightAnchor.constraint(equalTo: imageHolderView.rightAnchor, constant: -(bounds.width * 0.5))
    }
    
    private func checkForImageNills(){
        if pageImageView1.image == nil {
            pageImageView2leftConstraitInDoublePageMode?.constant = 0
        }
        if pageImageView2.image == nil {
            pageImageView2leftConstraitInDoublePageMode?.constant = bounds.width
        }
    }
    
    private func choosePageAsActive() {
        UIView.animate(withDuration: 0.1, animations: {
            self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: -2.5)
            self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.5, radius: 1)
            self.imageHolderView.alpha = 1
        }) { (_) in
        }
    }
    
    private func choosePageAsDiactive() {
        UIView.animate(withDuration: 0.1, animations: {
            self.imageHolderView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.imageHolderView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.2, radius: 1)
            self.imageHolderView.alpha = 0.6
        }) { (_) in
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
