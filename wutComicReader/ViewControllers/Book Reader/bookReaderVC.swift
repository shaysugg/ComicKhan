//
//  bookReaderVC.swift
//  wutComicReader
//
//  Created by Shayan on 6/25/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit


class BookReaderVC: UIViewController {
    
    //MARK:- Variables
    
    var comicPagesCount: Int = 0
    
    var comic : Comic? {
        didSet{
            guard let _ = comic else { return }
            //            comicPagesCount = (comic!.imageNames?.count ?? 0)
            //            comicPageNumberLabel.text = String(comicPagesCount)
            //            pageSlider.maximumValue = Float(comicPagesCount)
            titleLabel.text = comic?.name
        }
    }
    var lastViewedPage : Int?
    
    var menusAreAppeard: Bool = false
    
    var bookPageViewController : UIPageViewController!
    var bookSingleImages : [ComicImage] = []
    var bookDoubleImages : [(ComicImage? , ComicImage?)] = []
    var bookPages: [BookPage] = [] 
    
    var deviceIsLandscaped: Bool = UIDevice.current.orientation.isLandscape {
        didSet{
            thumbnailCollectionView.reloadData()
            setPageViewControllers()
            updateBookReaderValues()
        }
    }
    
    
    
    //MARK:- UI Variables
    
    lazy var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(thumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        collectionView.restorationIdentifier = "thumbnail"
        collectionView.backgroundColor = .appSystemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.clipsToBounds = true
        return collectionView
    }()
    
    lazy var pageSlider : UISlider = {
        let slider = UISlider(frame: .zero)
        slider.tintColor = .appBlue
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.setValue(1, animated: false)
        slider.setValue(1.00, animated: false)
        slider.addTarget(self, action: #selector(sliderDidChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchCancel)
        return slider
    }()
    
    lazy var currentPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        return label
    }()
    
    lazy var comicPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "50"
        return label
    }()
    
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 15)
        label.text = "BLAH!"
        label.textAlignment = .center
        label.textColor = .appMainLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .appSystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 15)
        return view
    }()
    
    lazy var dismissButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage( UIImage(named: "down") , for: .normal)
        button.addTarget(self, action: #selector(closeTheVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var bottomView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = .appSystemBackground
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    var bottomViewHeightConstrait: NSLayoutConstraint!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        setupDesign()
        setupPageController()
        disappearMenus(animated: false)
        
        addGestures()
        
        setupTopBar()
        setupBottomViewDesign()
        
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
        deviceIsLandscaped = UIDevice.current.orientation.isLandscape
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        deviceIsLandscaped = UIDevice.current.orientation.isLandscape
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let LastpageNumber = (comic?.lastVisitedPage) ?? 0
        updatePageSlider(with: Int(truncating: NSNumber(value: LastpageNumber)))
        updateBookReaderValues()
        
        
    }
    
    
    
    func setupBottomViewDesign(){
        
        view.addSubview(bottomView)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: 20).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: calculateBottomViewHeight()).isActive = true
        
        
        bottomView.layer.cornerRadius = 20
        bottomView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.5, radius: 25)
        
        bottomView.addSubview(pageSlider)
        pageSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.62).isActive = true
        pageSlider.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        pageSlider.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor, constant: -35).isActive = true
        
        bottomView.addSubview(currentPageNumberLabel)
        currentPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor, constant: 0).isActive = true
        currentPageNumberLabel.rightAnchor.constraint(equalTo: pageSlider.leftAnchor, constant: -17).isActive = true
        
        bottomView.addSubview(comicPageNumberLabel)
        comicPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor, constant: 0).isActive = true
        comicPageNumberLabel.leftAnchor.constraint(equalTo: pageSlider.rightAnchor, constant: 17).isActive = true
        
        bottomView.addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: pageSlider.topAnchor, constant: -5).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 10).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        
    }
    
    func calculateBottomViewHeight() -> CGFloat{
        var height :CGFloat?
        switch deviceType {
        case .iPad:
            height = (deviceIsLandscaped ? view.bounds.width : view.bounds.height) / 3.5
        case .smalliPhone:
            height = (deviceIsLandscaped ? view.bounds.width : view.bounds.height) / 3.2
        case .iPhone:
            height = (deviceIsLandscaped ? view.bounds.width : view.bounds.height) / 3
        case .iPhoneX:
            height = (deviceIsLandscaped ? view.bounds.width : view.bounds.height) / 3
        }
        print("bounds height is : \(view.bounds.height)")
        return height!
    }
    
    func setupTopBar(){
        
        view.addSubview(topBar)
        topBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50).isActive = true
        
        topBar.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 60).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: topBar.rightAnchor, constant: -30).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        
        topBar.addSubview(dismissButton)
        dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 20).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 27).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 27).isActive = true
        dismissButton.clipsToBounds = true
        
        
        
    }
    
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleMenusGestureTapped))
        tapGesture.numberOfTapsRequired = 1
        bookPageViewController.view.addGestureRecognizer(tapGesture)
        
        let doubletapGesture = UITapGestureRecognizer(target: self, action: #selector(zoomBookCurrentPage))
        doubletapGesture.numberOfTapsRequired = 2
        bookPageViewController.view.addGestureRecognizer(doubletapGesture)
        
        tapGesture.require(toFail: doubletapGesture)
        
    }
    
    func setLastViewedPageNumber(for currentBookPage: BookPage) {
        
        if let image1Number = (currentBookPage.pageImageView1.image as? ComicImage)?.pageNumber {
            lastViewedPage = bookSingleImages.firstIndex(where: {$0.pageNumber == image1Number})
        }else if let image2Number = (currentBookPage.pageImageView2.image as? ComicImage)?.pageNumber {
            lastViewedPage = bookSingleImages.firstIndex(where: {$0.pageNumber == image2Number})
        }
        
        if let _ = lastViewedPage {
            comic?.lastVisitedPage = Int16(lastViewedPage!)
        }
        
    }
    
    func updateBookReaderValues(){
        
        let lastVisitedPage = Int(comic?.lastVisitedPage ?? 0)
        let lastViewedBookPageIndex: Int?
        
        if deviceIsLandscaped {
            lastViewedBookPageIndex = doublePageIndexForPage(withNumber: lastVisitedPage)
        }else{
            lastViewedBookPageIndex = lastVisitedPage
        }
        
        
        
        if let _ = lastViewedBookPageIndex {
            thumbnailCollectionView.selectItem(at: IndexPath(row: lastViewedBookPageIndex!, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            bookPageViewController.setViewControllers([bookPages[lastViewedBookPageIndex!]], direction: .forward, animated: false, completion: nil)
            
            pageSlider.minimumValue = 1.0
            pageSlider.setValue(Float(lastViewedBookPageIndex!), animated: false)
            pageSlider.maximumValue = Float(bookPages.count)
            
            comicPageNumberLabel.text = "\(bookSingleImages.count)"
            configureCurrentPageLabelText(forBookPageIndex: lastViewedBookPageIndex!)
            
            
            
            
        }
    }
    
    func configureCurrentPageLabelText(forBookPageIndex index:Int) {
        
        guard index < bookDoubleImages.count else { return }
        
        if deviceIsLandscaped {
            var text = ""
            if let page1Number = bookDoubleImages[index].0?.pageNumber {
                text = String(page1Number + 1)
            }
            if let page2Number = bookDoubleImages[index].1?.pageNumber {
                if let _ = bookDoubleImages[index].0?.pageNumber {
                    text.append("-\(page2Number + 1)")
                }else{
                     text.append("\(page2Number + 1)")
                }
            }
            currentPageNumberLabel.text = text
        }else{
            currentPageNumberLabel.text = String(index + 1)
        }
        
    }
    
    @objc func zoomBookCurrentPage() {
        let currentPage = bookPageViewController.viewControllers?.first as? BookPage
        currentPage?.zoomWithDoubleTap()
        
    }
    
    
    @objc func closeTheVC(){
        if let page = lastViewedPage {
            
            comic?.lastVisitedPage = Int16(page)
            let context = AppFileManager().managedContext
            try? context?.save()
        }
        
        dismiss(animated: false, completion: nil)
    }
    
    
    
    
    //MARK:- Page Slider Functions
    
    func updatePageSlider(with value: Int){
        pageSlider.setValue(Float(value), animated: true)
        configureCurrentPageLabelText(forBookPageIndex: value - 1)
    }
    
    @objc func sliderDidChanged(){
        let value = Int(pageSlider.value)
        
        thumbnailCollectionView.scrollToItem(at: IndexPath(row: value - 1, section: 0), at: .centeredHorizontally, animated: false)
        setLastViewedPageNumber(for: bookPages[value - 1])
        configureCurrentPageLabelText(forBookPageIndex: value - 1)
    }
    
    @objc func sliderDidFinishedChanging(){
        let value = Int(pageSlider.value)
        thumbnailCollectionView.selectItem(at: IndexPath(row: value - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        let pendingPage = bookPages[value - 1]
        pendingPage.scrollView.setZoomScale(pendingPage.scrollView.minimumZoomScale, animated: false)
        bookPageViewController.setViewControllers([pendingPage], direction: .forward, animated: true, completion: nil)
        
    }
    
    
    
    //MARK:- Menues Appearing Handeling
    
    @objc func toggleMenusGestureTapped() {
        if menusAreAppeard {
            disappearMenus(animated: true)
        }else{
            appearMenus(animated: true)
        }
    }
    
    
    
    func disappearMenus(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 0.0
                self.dismissButton.alpha = 0.0
                self.topBar.alpha = 0.0
                
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0.1
            }) { (_) in
                self.titleLabel.alpha = 0.0
                self.dismissButton.alpha = 0.0
                self.topBar.alpha = 0.0
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0.1
                self.menusAreAppeard = false
            }
        }else{
            self.titleLabel.alpha = 0.0
            self.dismissButton.alpha = 0.0
            self.topBar.alpha = 0.0
            
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 500)
            self.bottomView.alpha = 0.0
            menusAreAppeard = false
        }
        
    }
    
    func appearMenus(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 1
                self.dismissButton.alpha = 1
                self.topBar.alpha = 1
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomView.alpha = 1
            }) { (_) in
                self.titleLabel.alpha = 1
                self.dismissButton.alpha = 1
                self.topBar.alpha = 1
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomView.alpha = 1
                self.menusAreAppeard = true
            }
        }else{
            self.titleLabel.alpha = 1
            self.dismissButton.alpha = 1
            self.topBar.alpha = 1
            
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.bottomView.alpha = 1
            menusAreAppeard = true
        }
        
    }
    
    
    
}



