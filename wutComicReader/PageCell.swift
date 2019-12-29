//
//  pageCell.swift
//  wutComicReader
//
//  Created by Shayan on 7/5/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell , UIScrollViewDelegate {
    
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
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
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
        let doubleTapZommingGesture = UITapGestureRecognizer(target: self, action: #selector(zoomWithDoubleTap))
        doubleTapZommingGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapZommingGesture)
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
        
        self.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.4, radius: 25)
        
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
        
//        print(superview?.tag)
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
    
    @objc func zoomWithDoubleTap() {
        
        let minScale = scrollView.minimumZoomScale
        if scrollView.zoomScale == minScale {
            scrollView.setZoomScale(minScale * 2.1, animated: true)
        }else{
            scrollView.setZoomScale(minScale, animated: true)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

