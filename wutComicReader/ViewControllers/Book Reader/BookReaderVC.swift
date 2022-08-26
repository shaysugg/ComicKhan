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
    
    private lazy var bottomBar: BottomBar = {
        let bar = BottomBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private lazy var topBar: TopBar = {
        let view = TopBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingBar: ReaderSettingVC = {
        let vc = ReaderSettingVC(settingDelegate: self)
        vc.view.layer.cornerRadius = 20
        vc.view.clipsToBounds = true
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //this used for fill the space between topBar and top device edge in iphone X
    //FIXME: You don't need this!
    lazy var topBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bookPageViewController : UIPageViewController!
    var currentPage: BookPage? {
        bookPageViewController.viewControllers?.first as? BookPage
    }
    
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
        setupPageController(pageMode: AppState.main.readerPageMode)
        
        disappearMenus(animated: false)
        
        addGestures()
        setupDesign()
        addGuideViewIfNeeded()
        observeAppStateChanges()
        
        bottomBar.thumbnailsDataSource = self
        bottomBar.thumbnailDelegate = self
        bottomBar.delegate = self
        bottomBar.comicPagesCount = comic?.imageNames?.count ?? 1
        topBar.delegate = self
        topBar.title = comic?.name
        
        
        let LastpageNumber = (comic?.lastVisitedPage) ?? 1
        setLastViewedPage(toPageWithNumber: Int(LastpageNumber), withAnimate: true)
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBar.invalidateThimbnailCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupDesign(){
        view.addSubview(bottomBar)
        view.addSubview(topBar)
        view.addSubview(topBarBackgroundView)
        
        
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
                bottomBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVCH: [
                bottomBar.widthAnchor.constraint(equalTo: view.widthAnchor),
                bottomBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: 0)
            ], CVRH: [
                bottomBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVRH: [
                bottomBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).withLowPiority(),
                bottomBar.heightAnchor.constraint(lessThanOrEqualToConstant: 280).withHighPiority(),
                bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -30)
            ])
        setupDynamicLayout()
        
    }
    
    
    func updateTopBarBackground() {
        topBarBackgroundView.backgroundColor = UIDevice.current.orientation.isLandscape ? UIColor.black.withAlphaComponent(0.7) : .appBackground
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
    
    
    func setLastViewedPage(toPageWithNumber number: Int, withAnimate animate: Bool = true, force: Bool = false) {
        
        //if numbers where not the same, set the bookpages in pageviewcontroller
        //if force is true set them any way
        let page1Number = currentPage?.image1?.pageNumber
        let page2Number = currentPage?.image2?.pageNumber
        
        if force || (page1Number != number && page2Number != number) {
            
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
    
    private func observeAppStateChanges() {
        AppState.main.$readerTheme
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .filter { $0 != nil }
            .sink { [weak self] theme in
                self?.currentPage?.setUpTheme(theme!)
            }.store(in: &cancellables)
        
        AppState.main.$readerPageMode
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .filter { $0 != nil }
            .sink { [weak self] pageMode in
                self?.configureBookPages(pageMode: pageMode!)
                if let page = self?.lastViewedPage {
                    self?.setLastViewedPage(toPageWithNumber: page, withAnimate: false, force: true)
                }
                self?.currentPage?.setUpPageMode(pageMode!)
                
            }.store(in: &cancellables)
    }
    
    @objc func zoomBookCurrentPage(_ sender: ZoomGestureRecognizer) {
        guard let point = sender.point else { return }
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
        
        func changes() {
            topBar.alpha = 0.0
            topBarBackgroundView.alpha = 0
            bottomBar.transform = CGAffineTransform(translationX: 0, y: bottomBar.frame.height + 30)
            bottomBar.alpha = 0.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                changes()
            }, completion: { _ in
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }else{
            changes()
        }
    }
    
    func appearMenus(animated: Bool) {
        menusAreAppeard = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        func changes() {
            self.topBar.alpha = 1
            self.bottomBar.transform = CGAffineTransform(translationX: 0, y: 0)
            self.bottomBar.alpha = 1
            self.topBarBackgroundView.alpha = 1
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                changes()
            }, completion: { _ in
            })
        }else{
            changes()
        }
        //FIXME: this shouldn't be there actually but idk wherever else i can make bottom bar collection view scroll
        let LastpageNumber = (comic?.lastVisitedPage) ?? 0
        bottomBar.currentPage = Int(LastpageNumber)
        
        
    }
    
    
    
    
    
}

extension BookReaderVC: TopBarDelegate, BottomBarDelegate {
    
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

extension BookReaderVC: ReaderSettingVCDelegate {
    func settingTapped() {
        presentSettingBar()
    }
    
    func doneButtonTapped() {
        dismissSettingBar()
    }
    
    func presentSettingBar() {
        blurView.effect = UIBlurEffect(style: .systemThinMaterial)
        
        view.addSubview(blurView)
        blurView.alpha = 0
        
        addChild(settingBar)
        view.addSubview(settingBar.view)
        settingBar.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            settingBar.view.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            settingBar.view.leftAnchor.constraint(equalTo: bottomBar.leftAnchor),
            settingBar.view.rightAnchor.constraint(equalTo: bottomBar.rightAnchor),
            settingBar.view.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        let shifting = settingBar.view.bounds.height + 40
        settingBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            self?.settingBar.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self?.blurView.alpha = 1
        } completion: { _ in}
        
//        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseIn) { [weak self] in
//            self?.bottomBar.transform = CGAffineTransform(translationX: 0, y: 200)
//            self?.bottomBar.alpha = 0
//
//        } completion: { _ in}
        
    }
    
    func dismissSettingBar() {
        
        let shifting = settingBar.view.bounds.height + 40
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.settingBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
            self?.blurView.alpha = 0
        } completion: { [weak self] _ in
            self?.settingBar.willMove(toParent: nil)
            self?.settingBar.removeFromParent()
            self?.settingBar.view.removeFromSuperview()
            self?.blurView.removeFromSuperview()
        }
        
        
        
    }
}

extension BookReaderVC: GuideViewDelegate {
    func viewElementsDidDissappeared() {
        guideView.removeFromSuperview()
    }
    
    
}
