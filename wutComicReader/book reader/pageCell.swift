//
//  pageCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/5/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class pageCell: UICollectionViewCell , UIScrollViewDelegate {
    
    var pageNumber: Int?
    
    var comicPage : UIImage? {
        didSet{
            pageImageView.image = comicPage
            updateMinZoomScaleForSize(bounds.size)
            centerTheImage()
            
        }
    }
    
    var scrollView : UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    var pageImageView : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.image = #imageLiteral(resourceName: "test")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var pageImageViewLeftAnchor: NSLayoutConstraint?
    var pageImageViewRightAnchor: NSLayoutConstraint?
    var pageImageViewTopAnchor: NSLayoutConstraint?
    var pageImageViewBottomAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pageImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        scrollView.delegate = self
        setupDesign()
        updateMinZoomScaleForSize(self.bounds.size)
        
        
        
    }
    
    
    func setupDesign() {
        
        addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        scrollView.addSubview(pageImageView)
        pageImageViewLeftAnchor = pageImageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        pageImageViewRightAnchor = pageImageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        pageImageViewBottomAnchor = pageImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        pageImageViewTopAnchor = pageImageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        pageImageViewLeftAnchor?.isActive = true
        pageImageViewRightAnchor?.isActive = true
        pageImageViewTopAnchor?.isActive = true
        pageImageViewBottomAnchor?.isActive = true
        
//        updateMinZoomScaleForSize(self.bounds.size)
    }
    

    
    //MARK:- Scroll View Delegates
    
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        
        guard let pageImageViewSize = pageImageView.image?.size else { return }
        
        let widthScale = size.width / pageImageViewSize.width
        let heightScale = size.height / pageImageViewSize.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pageImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerTheImage()
    }
    
    func centerTheImage(){
        
        let offset = (self.bounds.height - pageImageView.frame.height) / 2
        
        let yOffset = max(0, offset)
        
        pageImageViewTopAnchor?.constant = yOffset
        pageImageViewBottomAnchor?.constant = yOffset
        
        
        let xOffset = max(0, (self.bounds.width - pageImageView.frame.width) / 2)
        
        pageImageViewRightAnchor?.constant = xOffset
        pageImageViewLeftAnchor?.constant = xOffset
        
        layoutIfNeeded()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

