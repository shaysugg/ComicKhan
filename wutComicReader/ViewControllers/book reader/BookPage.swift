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
    
    var comicPage : UIImage? {
        didSet{
            pageImageView1.image = comicPage
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
    
    var imagesContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageContainerViewLeftAnchor: NSLayoutConstraint?
    var imageContainerViewRightAnchor: NSLayoutConstraint?
    var imageContainerViewTopAnchor: NSLayoutConstraint?
    var imageContainerViewBottomAnchor: NSLayoutConstraint?
    
    var pageImageView1 : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .cyan
        return imageView
    }()
    
    var pageImageView1LeftAnchor: NSLayoutConstraint?
    var pageImageView1DoubleModeRightAnchor: NSLayoutConstraint?
    var pageImageView1SingleModeRightAnchor: NSLayoutConstraint?
    var pageImageView1TopAnchor: NSLayoutConstraint?
    var pageImageView1BottomAnchor: NSLayoutConstraint?
    
    var pageImageView2 : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageImageView1.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        scrollView.delegate = self
        setupDesign()
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        updateMinZoomScaleForSize(view.bounds.size)
        
        
    }
    
    var haveDoublePage:Bool = UIDevice.current.orientation.isLandscape {
        didSet{
            
            if haveDoublePage{
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
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
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
        
        
        //            self.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.4, radius: 25)
        
    }
    
    func zoomWithDoubleTap() {
        
        let minScale = scrollView.minimumZoomScale
        if scrollView.zoomScale == minScale {
            scrollView.setZoomScale(minScale * 2.1, animated: true)
        }else{
            scrollView.setZoomScale(minScale, animated: true)
        }
    }
    
    
    
    //MARK:- Scroll View Delegates
    
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        
        guard let pageImageViewSize = pageImageView1.image?.size else { return }
        
        let widthScale = size.width / pageImageViewSize.width
        let heightScale = size.height / pageImageViewSize.height
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
        
//        print("Offset is \(yOffset) || scroll view content height is \(scrollView.contentSize.height) || scroll view bounds height is \(view.frame.height)")
        
//        imageContainerViewTopAnchor?.constant = yOffset
//        imageContainerViewBottomAnchor?.constant = yOffset
        
        if  haveDoublePage {
            
            let contentWidthSize = pageImageView1.bounds.width * 2
            let contentHeightSize = pageImageView1.bounds.height
            
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
            
            print("XOffset is \(xOffset)")
            print("scroll view content width is \(scrollView.contentSize.width)")
            print("contentSize width is \(pageImageView1.bounds.width)")
            print("scroll view bounds width is \(view.frame.width)")
            
        
        }else{
            
            let contentWidthSize = pageImageView1.bounds.width
            let contentHeightSize = pageImageView1.bounds.height
            
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
