//
//  PageController.swift
//  wutComicReader
//
//  Created by Sha Yan on 11/29/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

class BookPage: UIViewController , UIScrollViewDelegate {
    
    var pageNumber: Int?
    
    var doubleTapZoomingGesture: UITapGestureRecognizer!
    
    var comicPage : UIImage? {
        didSet{
            pageImageView.image = comicPage
            updateMinZoomScaleForSize(view.bounds.size)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        scrollView.delegate = self
        setupDesign()
        doubleTapZoomingGesture = UITapGestureRecognizer(target: self, action: #selector(zoomWithDoubleTap))
        doubleTapZoomingGesture.numberOfTapsRequired = 2
        
        scrollView.addGestureRecognizer(doubleTapZoomingGesture)
        updateMinZoomScaleForSize(view.bounds.size)
        
    }
    
    
    
    
    func setupDesign() {
        
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        scrollView.addSubview(pageImageView)
        pageImageViewLeftAnchor = pageImageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        pageImageViewRightAnchor = pageImageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        pageImageViewBottomAnchor = pageImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        pageImageViewTopAnchor = pageImageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        pageImageViewLeftAnchor?.isActive = true
        pageImageViewRightAnchor?.isActive = true
        pageImageViewTopAnchor?.isActive = true
        pageImageViewBottomAnchor?.isActive = true
        
        //            self.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.4, radius: 25)
        
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
        
        let offset = (view.bounds.height - pageImageView.frame.height) / 2
        
        let yOffset = max(0, offset)
        
        pageImageViewTopAnchor?.constant = yOffset
        pageImageViewBottomAnchor?.constant = yOffset
        
        
        let xOffset = max(0, (view.bounds.width - pageImageView.frame.width) / 2)
        
        pageImageViewRightAnchor?.constant = xOffset
        pageImageViewLeftAnchor?.constant = xOffset
        
        view.layoutIfNeeded()
        
    }
    
    @objc func zoomWithDoubleTap() {
        
        let minScale = scrollView.minimumZoomScale
        if scrollView.zoomScale == minScale {
            scrollView.setZoomScale(minScale * 2.1, animated: true)
        }else{
            scrollView.setZoomScale(minScale, animated: true)
        }
    }
    
    
}
