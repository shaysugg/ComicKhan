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
    
    lazy var scrollView : UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    lazy var imagesContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageContainerViewLeftAnchor: NSLayoutConstraint?
    var imageContainerViewRightAnchor: NSLayoutConstraint?
    var imageContainerViewTopAnchor: NSLayoutConstraint?
    var imageContainerViewBottomAnchor: NSLayoutConstraint?
    
    lazy var pageImageView1 : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var pageImageView1LeftAnchor: NSLayoutConstraint?
    var pageImageView1DoubleModeRightAnchor: NSLayoutConstraint?
    var pageImageView1SingleModeRightAnchor: NSLayoutConstraint?
    var pageImageView1TopAnchor: NSLayoutConstraint?
    var pageImageView1BottomAnchor: NSLayoutConstraint?
    
    lazy var pageImageView2 : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        setupDesign()
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        updateMinZoomScaleForSize(view.bounds.size)
        
        
    }
    
    var isDoupleSplashPage = false {
        didSet {
            if isDoupleSplashPage {
                pageImageView2.removeFromSuperview()
                pageImageView1DoubleModeRightAnchor?.isActive = false
                pageImageView1SingleModeRightAnchor?.isActive = true
            }
        }
    }
    
    
    var haveDoublePage:Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
        centerTheImage()
    }
    
    
    func setupDesign() {
        
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.backgroundColor = .appSystemSecondaryBackground
        
        scrollView.addSubview(imagesContainerView)
        imageContainerViewLeftAnchor = imagesContainerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        imageContainerViewRightAnchor = imagesContainerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        imageContainerViewBottomAnchor = imagesContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        imageContainerViewTopAnchor = imagesContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageContainerViewLeftAnchor?.isActive = true
        imageContainerViewRightAnchor?.isActive = true
        imageContainerViewBottomAnchor?.isActive = true
        imageContainerViewTopAnchor?.isActive = true
        
        imagesContainerView.addSubview(pageImageView1)
        pageImageView1.leftAnchor.constraint(equalTo: imagesContainerView.leftAnchor).isActive = true
        pageImageView1SingleModeRightAnchor = pageImageView1.rightAnchor.constraint(equalTo: imagesContainerView.rightAnchor)
        pageImageView1.bottomAnchor.constraint(equalTo: imagesContainerView.bottomAnchor).isActive = true
        pageImageView1.topAnchor.constraint(equalTo: imagesContainerView.topAnchor).isActive = true
        pageImageView1SingleModeRightAnchor?.isActive = true
        
        
    }
    
    func zoomWithDoubleTap() {
        
        let minScale = scrollView.minimumZoomScale
        if scrollView.zoomScale == minScale {
            scrollView.setZoomScale(minScale * 2.1, animated: true)
        }else{
            scrollView.setZoomScale(minScale, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        if haveDoublePage {
            imagesContainerView.addSubview(pageImageView2)
            
            pageImageView1SingleModeRightAnchor?.isActive = false
            pageImageView1DoubleModeRightAnchor?.isActive = true
            
            pageImageView2.leftAnchor.constraint(equalTo: pageImageView1.rightAnchor).isActive = true
            pageImageView2.rightAnchor.constraint(equalTo: imagesContainerView.rightAnchor).isActive = true
            pageImageView2.bottomAnchor.constraint(equalTo: imagesContainerView.bottomAnchor).isActive = true
            pageImageView2.topAnchor.constraint(equalTo: imagesContainerView.topAnchor).isActive = true
            
        }else{
            pageImageView2.removeFromSuperview()
            pageImageView1DoubleModeRightAnchor?.isActive = false
            pageImageView1SingleModeRightAnchor?.isActive = true
            
        }
        
//        handleViewsWhereOneImagesIsNill()
        
    }
    
    private func pagesThatHaveImage() -> [UIImageView] {
        var imageViews: [UIImageView] = []
        if let _ = pageImageView2.image {
            imageViews.append(pageImageView2)
        }
        if let _ = pageImageView1.image {
            imageViews.append(pageImageView1)
        }
        return imageViews
    }
    
    
    
    
    
    //MARK:- Scroll View Delegates
    
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        
        if pagesThatHaveImage().isEmpty { return }
        
        let imageViewSize = pagesThatHaveImage()[0].image!.size
        
        let widthScale = size.width / imageViewSize.width
        let heightScale = size.height / imageViewSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagesContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerTheImage()

    }
    
    
    func centerTheImage(){
        
        let yOffset = max(0 ,(scrollView.bounds.height - scrollView.contentSize.height) / 2)
        
        if pagesThatHaveImage().isEmpty { return }
        
        let imageView = pagesThatHaveImage()[0]
        let numberOfPages = pagesThatHaveImage().count
        
        if  haveDoublePage {

            let contentWidthSize = imageView.bounds.width * CGFloat(numberOfPages)
            let contentHeightSize = imageView.bounds.height
            
            pageImageView1DoubleModeRightAnchor?.isActive = true
            pageImageView1SingleModeRightAnchor?.isActive = false
            
            let yOffset = max(0 ,(scrollView.bounds.height - (scrollView.zoomScale * contentHeightSize)) / 2)
                    
            imageContainerViewTopAnchor?.constant = yOffset
            imageContainerViewBottomAnchor?.constant = yOffset
            
            let xOffset = max(0, (scrollView.bounds.width - ( scrollView.zoomScale * contentWidthSize)) / 2)
            pageImageView1DoubleModeRightAnchor?.constant = xOffset
            pageImageView1LeftAnchor?.constant = xOffset
            imageContainerViewLeftAnchor?.constant = xOffset
            imageContainerViewRightAnchor?.constant = xOffset
        
        }else{
            
            let contentWidthSize = imageView.bounds.width
            let contentHeightSize = imageView.bounds.height
            
            pageImageView1DoubleModeRightAnchor?.isActive = false
            pageImageView1SingleModeRightAnchor?.isActive = true
            
            let yOffset = max(0 ,(scrollView.bounds.height - (scrollView.zoomScale * contentHeightSize)) / 2)
            imageContainerViewTopAnchor?.constant = yOffset
            pageImageView1BottomAnchor?.constant = yOffset
            
            let xOffset = max(0, (scrollView.bounds.width - (scrollView.zoomScale * contentWidthSize)) / 2)
            pageImageView1SingleModeRightAnchor?.constant = xOffset
            imageContainerViewRightAnchor?.constant = xOffset
            imageContainerViewLeftAnchor?.constant = xOffset
            pageImageView1LeftAnchor?.constant = xOffset

        }
        
        
        view.layoutIfNeeded()
        
    }
    
    
}
