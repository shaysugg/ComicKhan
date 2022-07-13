//
//  bookReaderVC.swift
//  wutComicReader
//
//  Created by Shayan on 6/25/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import Combine



protocol TopBarDelegate: AnyObject {
    func dismissViewController()
}

final class BookReaderVC: DynamicConstraintViewController {
    
    //MARK: Variables
    
    var comic : Comic? {
        didSet{
            guard let _ = comic else { return }
        }
    }
    

    
    var lastViewedPage : Int?
    var menusAreAppeard: Bool = false
    
    
    var bookSingleImages : [ComicImage] = []
    var bookDoubleImages : [(ComicImage? , ComicImage?)] = []
    var bookPages: [BookPage] = []
    
    var thumbnailImages: [ComicImage] = []
    
    
    private var compactConstaitns: [NSLayoutConstraint] = []
    private var regularConstraint: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    var comicReadingProgressDidChanged: ((_ comic: Comic, _ lastPageHasRead: Int) -> Void)?
    
    var cancellables = Set<AnyCancellable>()
    
    
    //MARK: UI Variables
    
    lazy var bottomBar: BottomBar = {
        let bar = BottomBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    lazy var topBar: TopBar = {
        let view = TopBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //this used for fill the space between topBar and top device edge in iphone X
    //FIXME: You don't need this!
    lazy var topBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .appSystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bookPageViewController : UIPageViewController!
    
    private lazy var guideView: ReaderGuideView = {
        let view = ReaderGuideView()
        return view
    }()
    
    override var prefersStatusBarHidden: Bool {
        return !menusAreAppeard
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIDevice.current.orientation.isLandscape ?  .lightContent : .default
    }
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController(pageMode: AppState.main.bookReaderPageMode)
        
        disappearMenus(animated: false)
        
        addGestures()
        setupDesign()
        addGuideViewIfNeeded()
        
        bottomBar.thumbnailDelegate = self
        bottomBar.delegate = self
        bottomBar.comicPagesCount = comic?.imageNames?.count ?? 1
        topBar.delegate = self
        topBar.title = comic?.name
        
        
        let LastpageNumber = (comic?.lastVisitedPage) ?? 0
        setLastViewedPage(toPageWithNumber: Int(LastpageNumber), withAnimate: true)
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(UIScreen.main.traitCollection.verticalSizeClass)
        print(UIScreen.main.traitCollection.horizontalSizeClass)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let LastpageNumber = (comic?.lastVisitedPage) ?? 0
        setLastViewedPage(toPageWithNumber: Int(LastpageNumber), withAnimate: true)
    }
    
    
    
    func setupDesign(){
        view.addSubview(bottomBar)
        view.addSubview(topBar)
        view.addSubview(topBarBackgroundView)
        
        let larg = view.bounds.width > view.bounds.height ? view.bounds.width : view.bounds.height
        let short = view.bounds.width > view.bounds.height ? view.bounds.height : view.bounds.width
        
        
        setConstraints(shared: [
            topBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            topBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            bottomBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            topBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topBarBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topBarBackgroundView.bottomAnchor.constraint(equalTo: topBar.topAnchor)
            
        ])
        
        setConstraints(
            CVCH: [
                bottomBar.widthAnchor.constraint(equalToConstant: (larg * 2) / 3),
                bottomBar.heightAnchor.constraint(equalToConstant: short / 2),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVCH: [
                bottomBar.widthAnchor.constraint(equalToConstant: short),
                bottomBar.heightAnchor.constraint(equalToConstant: larg / 3.8),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: 0)
            ], CVRH: [
                bottomBar.widthAnchor.constraint(equalToConstant: larg / 2),
                bottomBar.heightAnchor.constraint(equalToConstant: short / 2),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVRH: [
                bottomBar.widthAnchor.constraint(equalToConstant: larg / 2),
                bottomBar.heightAnchor.constraint(equalToConstant: short / 3),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -30)
            ])
        setupDynamicLayout()
        
    }
    
    
    func updateTopBarBackground() {
        topBarBackgroundView.backgroundColor = UIDevice.current.orientation.isLandscape ? UIColor.black.withAlphaComponent(0.7) : .appSystemBackground
    }
    
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleMenusGestureTapped))
        tapGesture.numberOfTapsRequired = 1
        bookPageViewController.view.addGestureRecognizer(tapGesture)
        
        let doubletapGesture = ZoomGestureRecognizer(target: self, action: #selector(zoomBookCurrentPage(_:)))
        doubletapGesture.numberOfTapsRequired = 2
        bookPageViewController.view.addGestureRecognizer(doubletapGesture)
        
        tapGesture.require(toFail: doubletapGesture)
        
    }
    
    private func addGuideViewIfNeeded() {
        if AppState.main.readerPresentForFirstTime() {
            
            guideView.delegate = self
            
            view.addSubview(guideView)
            
            guideView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            guideView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            guideView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            guideView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
        }
    }
    
    
    func setLastViewedPage(toPageWithNumber number: Int, withAnimate animate: Bool = true) {
        
        let bookPage = bookPageViewController.viewControllers?.first as! BookPage
        let page1Number = bookPage.image1?.pageNumber
        let page2Number = bookPage.image2?.pageNumber
        
        if page1Number != number && page2Number != number {
            
            let pendingPage = bookPages.first {
                return $0.image1?.pageNumber == number || $0.image2?.pageNumber == number
            }
            
            if let _ = pendingPage {
                bookPageViewController.setViewControllers([pendingPage!], direction: .forward, animated: animate, completion: nil)
            }
            
        }
        
        //update bottomBar variables
        if number != bottomBar.currentPage {
            bottomBar.currentPage = number
        }
        
        //update comic.lastvisitedPage
        //FIXME: In double splash pages the number is smh NIL and not getting stored as the lastPage
        lastViewedPage = number
        if let _ = lastViewedPage {
            comic?.lastVisitedPage = Int16(lastViewedPage!)
        }
        
    }
    
    @objc func zoomBookCurrentPage(_ sender: ZoomGestureRecognizer) {
        guard let point = sender.point else { return }
        let currentPage = bookPageViewController.viewControllers?.first as? BookPage
        currentPage?.zoomWithDoubleTap(toPoint: point)
        
    }
    
    //MARK: Menues Appearing Handeling
    
    @objc func toggleMenusGestureTapped() {
        if menusAreAppeard {
            disappearMenus(animated: true)
        }else{
            appearMenus(animated: true)
        }
    }
    
    
    
    func disappearMenus(animated: Bool) {
        menusAreAppeard = false
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.topBar.alpha = 0.0
                self.topBarBackgroundView.alpha = 0
                self.bottomBar.transform = CGAffineTransform(translationX: 0, y: self.bottomBar.frame.height + 30)
                self.bottomBar.alpha = 0.1
                
            }, completion: { _ in
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }else{
            topBar.alpha = 0.0
            topBarBackgroundView.alpha = 0
            bottomBar.transform = CGAffineTransform(translationX: 0, y: bottomBar.frame.height + 30)
            bottomBar.alpha = 0.0
        }
    }
    
    func appearMenus(animated: Bool) {
        menusAreAppeard = true
        self.setNeedsStatusBarAppearanceUpdate()
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.topBar.alpha = 1
                self.bottomBar.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomBar.alpha = 1
                self.topBarBackgroundView.alpha = 1
                //
            }, completion: { _ in
                
            })
        }else{
            topBar.alpha = 1
            topBarBackgroundView.alpha = 1
            bottomBar.transform = CGAffineTransform(translationX: 0, y: 0)
            bottomBar.alpha = 1
            
        }
        //this shouldn't be there actually but idk wherever else i can make bottom bar collection view scroll
        let LastpageNumber = (comic?.lastVisitedPage) ?? 0
        bottomBar.currentPage = Int(LastpageNumber)
        
        
    }
    
    
    
}

extension BookReaderVC: TopBarDelegate, BottomBarDelegate {
    func pageModeChanged(to pageMode: BookReaderPageMode) {
        AppState.main.setbookReaderPageMode(pageMode)
        setBookPageViewControllers(pageMode: pageMode)
        if let page = lastViewedPage {
            setLastViewedPage(toPageWithNumber: page, withAnimate: false)
        }
        if let page = bookPageViewController.viewControllers?.first as? BookPage {
            page.updateForPageMode()
        }
    }
    
    func dismissViewController() {
        comicReadingProgressDidChanged?(comic!, lastViewedPage ?? 0)
        
        bottomBar.delegate = nil
        topBar.delegate = nil
        
        dismiss(animated: false, completion: nil)
        
    }
    
    func newPageBeenSet(pageNumber: Int) {
        setLastViewedPage(toPageWithNumber: pageNumber)
    }
    
    
}

extension BookReaderVC: GuideViewDelegate {
    func viewElementsDidDissappeared() {
        guideView.removeFromSuperview()
    }
    
    
}
