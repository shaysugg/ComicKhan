//
//  bookReaderVC.swift
//  wutComicReader
//
//  Created by Shayan on 6/25/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import Combine




final class BookReaderVC: DynamicConstraintViewController {
    
    //MARK: Variables
    
    var comic : Comic?
    
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
    
    private lazy var thumbnailBar: ReaderThumbnailVC = {
        let vc = ReaderThumbnailVC(thumbnailDelegate: self,
                                   thumbnailImages: thumbnailImages,
                                   comicName: comic?.name ?? "")
        vc.view.clipsToBounds = true
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    
    private lazy var bottomBarsPlaceHolder: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    private lazy var settingBar: ReaderSettingVC = {
        let vc = ReaderSettingVC(settingDelegate: self)
        vc.view.clipsToBounds = true
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dismissButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        let img = UIImage(named: "close")?.withTintColor(.appMainLabelColor)
        button.setImage(img, for: .normal)
        button.backgroundColor = .appBackground
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        
        addGestures()
        setupDesign()
        addGuideViewIfNeeded()
        observeAppStateChanges()
        
        disappearDismissButton(animated: false)
        
        setToLastVisitedPage()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupDesign(){
        view.addSubview(bottomBarsPlaceHolder)
        
        
        view.addSubview(dismissButton)
        dismissButton.layer.cornerRadius = 20
        setConstraints(shared: [
            dismissButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            dismissButton.widthAnchor.constraint(equalTo: dismissButton.heightAnchor),
            
            bottomBarsPlaceHolder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
        
        setConstraints(
            CVCH: [
                bottomBarsPlaceHolder.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBarsPlaceHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
                bottomBarsPlaceHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVCH: [
                bottomBarsPlaceHolder.widthAnchor.constraint(equalTo: view.widthAnchor),
                bottomBarsPlaceHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                bottomBarsPlaceHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: 0)
            ], CVRH: [
                bottomBarsPlaceHolder.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBarsPlaceHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
                bottomBarsPlaceHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20)
            ], RVRH: [
                bottomBarsPlaceHolder.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                bottomBarsPlaceHolder.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).withLowPiority(),
                bottomBarsPlaceHolder.heightAnchor.constraint(lessThanOrEqualToConstant: 280).withHighPiority(),
                bottomBarsPlaceHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -30)
            ])
        setupDynamicLayout()
        
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
    
    private func setToLastVisitedPage() {
        var LastpageNumber: Int {
            if comic?.lastVisitedPage == nil || comic?.lastVisitedPage == 0 {
                return 1
            }else {
                return Int(comic!.lastVisitedPage)
            }
        }
        setLastViewedPage(toPageWithNumber: Int(LastpageNumber), withAnimate: true)
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
        if thumbnailBar.isBeingPresented {
            thumbnailBar.setCurrentPage(to: number)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dismissButton.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 7)
        thumbnailBar.view.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 10)
//        settingBar.view.makeDropShadow(shadowOffset: .zero, opacity: 0.5, radius: 10)
    }
    
    @objc func zoomBookCurrentPage(_ sender: ZoomGestureRecognizer) {
        guard let point = sender.point else { return }
        currentPage?.zoomWithDoubleTap(toPoint: point)
        
    }
    
    @objc func dismissViewController() {
        comicReadingProgressDidChanged?(comic!, lastViewedPage ?? 0)
        dismiss(animated: false, completion: nil)
        
    }
    
    @objc func toggleMenusGestureTapped() {
        if menusAreAppeard {
            disappearDismissButton(animated: true)
            disapearThumbnailBar(animated: true)
        }else{
            appearDismissButton(animated: true)
            appearThumbnailVC(animated: true)
        }
        
        menusAreAppeard.toggle()
    }
    
}


extension BookReaderVC: GuideViewDelegate {
    func viewElementsDidDissappeared() {
        guideView.removeFromSuperview()
    }
}

extension BookReaderVC: ThumbnailVCDelegate {
    func newPageBeenSet(pageNumber: Int) {
        setLastViewedPage(toPageWithNumber: pageNumber)
    }
    
}



//MARK: Menu Appearing
extension BookReaderVC {
    
    func appearDismissButton(animated: Bool) {
        
        let changes: () -> Void = { [weak self] in
            self?.dismissButton.alpha = 1
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: changes, completion: { _ in })
        } else {
            changes()
        }
    }
    
    
    func disappearDismissButton(animated: Bool) {
        
        let changes: () -> Void = { [weak self] in
            self?.dismissButton.alpha = 0
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: changes, completion: {_ in })
        } else {
            changes()
        }
        
        
    }
    
    
    func appearThumbnailVC(animated: Bool) {
        addChild(thumbnailBar)
        view.addSubview(thumbnailBar.view)
        thumbnailBar.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            thumbnailBar.view.topAnchor.constraint(equalTo: bottomBarsPlaceHolder.topAnchor),
            thumbnailBar.view.leftAnchor.constraint(equalTo: bottomBarsPlaceHolder.leftAnchor),
            thumbnailBar.view.rightAnchor.constraint(equalTo: bottomBarsPlaceHolder.rightAnchor),
            thumbnailBar.view.bottomAnchor.constraint(equalTo: bottomBarsPlaceHolder.bottomAnchor),
        ])
        
        let shifting = thumbnailBar.view.bounds.height + 40
        thumbnailBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
        
        let changes: () -> Void = { [weak self] in
            self?.thumbnailBar.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        let complition: (Bool) -> Void = { [weak self] _ in
            if let lastViewedPage = self?.lastViewedPage {
                self?.thumbnailBar.setCurrentPage(to: lastViewedPage)
            }
        }
        if animated {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: changes, completion: complition)
        } else {
            changes()
            complition(true)
        }
    }
    
    
    func disapearThumbnailBar(animated: Bool) {
        
        let shifting = thumbnailBar.view.bounds.height + 40
        
        let changes: () -> Void = { [weak self] in
            self?.thumbnailBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
        }
        
        let complition: (Bool) -> Void = { [weak self] _ in
            self?.thumbnailBar.willMove(toParent: nil)
            self?.thumbnailBar.removeFromParent()
            self?.thumbnailBar.view.removeFromSuperview()
        }
        
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: changes, completion: complition)
        } else {
            changes()
            complition(true)
        }
    }
}



extension BookReaderVC: ReaderSettingVCDelegate {
    func settingTapped() {
        presentSettingBar(animated: true)
    }
    
    func doneButtonTapped() {
        dismissSettingBar(animated: true)
    }
    
    func presentSettingBar(animated: Bool) {
        blurView.effect = UIBlurEffect(style: .systemThinMaterial)
        
        view.addSubview(blurView)
        blurView.alpha = 0
        
        addChild(settingBar)
        view.addSubview(settingBar.view)
        settingBar.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            settingBar.view.topAnchor.constraint(equalTo: bottomBarsPlaceHolder.topAnchor),
            settingBar.view.leftAnchor.constraint(equalTo: bottomBarsPlaceHolder.leftAnchor),
            settingBar.view.rightAnchor.constraint(equalTo: bottomBarsPlaceHolder.rightAnchor),
            settingBar.view.bottomAnchor.constraint(equalTo: bottomBarsPlaceHolder.bottomAnchor),
            
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        let shifting = settingBar.view.bounds.height + 40
        settingBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
        
        let changes = { [weak self] in
            self?.settingBar.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self?.blurView.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: changes, completion: { _ in})
        } else {
            changes()
        }
        
    }
    
    func dismissSettingBar(animated: Bool) {
        
        let shifting = settingBar.view.bounds.height + 40
        
        let changes = { [weak self] in
            self?.settingBar.view.transform = CGAffineTransform(translationX: 0, y: shifting)
            self?.blurView.alpha = 0
        }
        
        let complition: (Bool) -> Void = { [weak self] _ in
            self?.settingBar.willMove(toParent: nil)
            self?.settingBar.removeFromParent()
            self?.settingBar.view.removeFromSuperview()
            self?.blurView.removeFromSuperview()
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: changes, completion: complition)
        } else {
            changes()
            complition(true)
        }
        
        
        
    }
}
