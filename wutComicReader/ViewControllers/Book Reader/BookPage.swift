//
//  PageController.swift
//  wutComicReader
//
//  Created by Sha Yan on 11/29/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit

final class BookPage: UIViewController , UIScrollViewDelegate {
    
    //MARK: Variables
    
    var pageNumber: Int?
    
    var image1: ComicImage?
    var image2: ComicImage?
    
    //MARK: UI Variables
    
    lazy var scrollView : UIScrollView! = {
        let scrollview = UIScrollView()
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentInsetAdjustmentBehavior = .never
        return scrollview
    }()
    
    lazy var imagesContainerView : UIStackView = {
        let view = UIStackView()
        view.spacing = 0
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
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
    
    lazy var pageImageView2 : UIImageView = {
        
        let imageView = UIImageView(frame: .zero )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var gradientLayer: CAGradientLayer?

    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        scrollView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if pageImageView1.image?.size == .zero ||
            pageImageView1.image?.size == nil{
            
            pageImageView1.image = UIImage(contentsOfFile: image1?.path ?? "")
            pageImageView2.image = UIImage(contentsOfFile: image2?.path ?? "")
            
            updateMinZoomScaleForSize(view.bounds.size)
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
            
            setUpPageMode(AppState.main.readerPageMode)
            setUpTheme(AppState.main.readerTheme)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageImageView1.image = UIImage()
        pageImageView2.image = UIImage()
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
        
        scrollView.addSubview(imagesContainerView)
        imageContainerViewLeftAnchor = imagesContainerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        imageContainerViewRightAnchor = imagesContainerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        imageContainerViewBottomAnchor = imagesContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        imageContainerViewTopAnchor = imagesContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageContainerViewLeftAnchor?.isActive = true
        imageContainerViewRightAnchor?.isActive = true
        imageContainerViewBottomAnchor?.isActive = true
        imageContainerViewTopAnchor?.isActive = true
        
        imagesContainerView.addArrangedSubview(pageImageView1)
        
        
    }
    
    func zoomWithDoubleTap(toPoint point:CGPoint, animated: Bool = true) {
        
        let minScale = scrollView.minimumZoomScale
        if scrollView.zoomScale == minScale {
            
            var zoomRect = CGRect()
            zoomRect.size.width = (imagesContainerView.frame.size.width / scrollView.maximumZoomScale) * 2.3
            zoomRect.size.height = (imagesContainerView.frame.size.height / scrollView.maximumZoomScale) * 2.3
            let newCenter = scrollView.convert(point, to: imagesContainerView)
            zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2)
            zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2)
            
            scrollView.zoom(to: zoomRect, animated: animated)
        }else{
            scrollView.setZoomScale(minScale, animated: animated)
        }
    }
    
    
    
    private func pagesThatHaveImage() -> [UIImageView] {
        [pageImageView1, pageImageView2].filter{ $0.image != nil && $0.image != UIImage() }
    }
    
    private func configureBackgroundGradient() {
        guard let image1 = pageImageView1.image,
              let color1 = image1.getPixelColor(pos: CGPoint()) else { return }

        let image2 = pageImageView2.image ?? image1
        guard let color2 = image2.getPixelColor(
            pos: CGPoint(x: image2.size.width - 1, y: image2.size.height - 1))
        else { return }
        
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.colors = [color1.cgColor, color2.cgColor]
        gradientLayer!.locations = [0 , 1]
        gradientLayer!.frame = view.bounds
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    func setBackgroundColor(to color: UIColor) {
        gradientLayer?.removeFromSuperlayer()
        view.backgroundColor = color
    }
    
    func setUpTheme(_ theme: ReaderTheme) {
        switch theme {
        case .dynamic:
            configureBackgroundGradient()
        case .light:
            setBackgroundColor(to: .white)
        case .dark:
            setBackgroundColor(to: .black)
        case .system:
            setBackgroundColor(to: .systemBackground)
        }
    }
    
    func setUpPageMode(_ pageMode: ReaderPageMode) {
        switch pageMode {
        case .single:
            pageImageView2.removeFromSuperview()
        case .double:
            imagesContainerView.addArrangedSubview(pageImageView2)
        }
        
        updateMinZoomScaleForSize(view.bounds.size)
        centerTheImage()
    }
    
    
    //MARK: Scroll View Delegates
    
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        
        
        guard let imagesHeight = pagesThatHaveImage().first?.image?.size.height else {
            return
        }
        
        let imagesWidth = (pageImageView1.image?.size.width ?? 0) + (pageImageView2.image?.size.width ?? 0)
        print("------------")
        print(pageImageView1.image?.size.width)
        print(pageImageView2.image?.size.width)
        
        let widthScale = size.width / imagesWidth
        let heightScale = size.height / imagesHeight
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagesContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerTheImage()

    }
    
    
    func centerTheImage(){
        
        if pagesThatHaveImage().isEmpty { return }
        
        let imageView = pagesThatHaveImage()[0]
        let numberOfPages = pagesThatHaveImage().count
        
        if AppState.main.readerPageMode == .single {
            centerForPortraitMode(imageView)
        } else {
            centerForLandscapeMode(imageView, withNumberOfPages: numberOfPages)
        }
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
    }
    
    
    private func centerForLandscapeMode(_ imageView: UIImageView, withNumberOfPages pageNumbers: Int){
        let contentWidthSize = imageView.image!.size.width * CGFloat(pageNumbers)
        let contentHeightSize = imageView.image!.size.height
        
        //FIXME: Why imageView.frame is ZERO?
        // if any of sizes be zero then centering gonna be a disaster (send the image out of screen)
        // it's better to not center at that situation (still keeps the image in screen bouderies)
        if contentHeightSize.isZero || contentWidthSize.isZero { return }
        
        let yOffset = max(0 ,(scrollView.bounds.height - (scrollView.zoomScale * contentHeightSize)) / 2)
                
        imageContainerViewTopAnchor?.constant = yOffset
        imageContainerViewBottomAnchor?.constant = yOffset
        
        let xOffset = max(0, (scrollView.bounds.width - ( scrollView.zoomScale * contentWidthSize)) / 2)
        imageContainerViewLeftAnchor?.constant = xOffset
        imageContainerViewRightAnchor?.constant = xOffset
    }
    
    private func centerForPortraitMode(_ imageView: UIImageView){
        //FIXME: SHOULD CHANG BOUNDS TO IMAGE BUT WHY???????????
        let contentWidthSize = imageView.image!.size.width
        let contentHeightSize = imageView.image!.size.height
        
        //line 281 comment!
        if contentHeightSize.isZero || contentWidthSize.isZero { return }
        
        let yOffset = max(0 ,(scrollView.bounds.height - (scrollView.zoomScale * contentHeightSize)) / 2)
        imageContainerViewTopAnchor?.constant = yOffset
        imageContainerViewBottomAnchor?.constant = yOffset
        
        let xOffset = max(0, (scrollView.bounds.width - (scrollView.zoomScale * contentWidthSize)) / 2)
        imageContainerViewRightAnchor?.constant = xOffset
        imageContainerViewLeftAnchor?.constant = xOffset
        
    }
    
}


