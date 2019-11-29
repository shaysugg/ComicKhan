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
    
    var comic : Comic? {
        didSet{
            comicPageNumberLabel.text = String(comic!.pageNumbers)
            pageSlider.maximumValue = Float(comic!.pageNumbers)
            titleLabel.text = comic?.name
        }
    }
    var lastViewedPage : Int?
    var menusAreAppeard: Bool = false
    
    var previousCell : thumbnailCell?
    
    var bookCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionview.isPagingEnabled = true
        collectionview.register(PageCell.self, forCellWithReuseIdentifier: "pageCell")
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.restorationIdentifier = "book"
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = .appSystemSecondaryBackground
        collectionview.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionview.tag = 101
        return collectionview
    }()
    
    
    var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(thumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        collectionView.restorationIdentifier = "thumbnail"
        collectionView.backgroundColor = .appSystemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var pageSlider : UISlider = {
        let slider = UISlider(frame: .zero)
        slider.tintColor = .appBlue
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.setValue(1.00, animated: false)
        slider.addTarget(self, action: #selector(sliderDidChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidFinishedChanging), for: .touchUpInside)
        return slider
    }()
    
    var currentPageNumberLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        return label
    }()
    
    var comicPageNumberLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 14)
        label.textColor = .appSeconedlabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "50"
        return label
    }()
    
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: appFontRegular, size: 15)
        label.text = "BLAH!"
        label.textAlignment = .center
        label.textColor = .appMainLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .appSystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeDropShadow(shadowOffset: .zero, opacity: 0.3, radius: 15)
        return view
    }()
    
    var dismissButton : UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage( UIImage(named: "down") , for: .normal)
        button.addTarget(self, action: #selector(closeTheVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var bottomView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = .appSystemBackground
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    lazy var appearingMenuTapGesture : UIPanGestureRecognizer = {
////        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(appearTapGestureTapped))
////        tapGesture.numberOfTapsRequired = 1
////        tapGesture.numberOfTouchesRequired = 1
////        tapGesture.cancelsTouchesInView = true
////        tapGesture.delaysTouchesBegan = true
////        return tapGesture
//
//
//    }()
    
    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        disappearMenus(animated: false)
        
        addGestures()
        
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
        
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
        
        
        
        
       
    }
    
    
    override func viewDidLayoutSubviews() {
//        view.backgroundColor = .appSystemFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let LastpageNumber = getLastviewedPage()
        updatePageSlider(with: LastpageNumber)
        bookCollectionView.isUserInteractionEnabled = false
        bookCollectionView.scrollToItem(at: IndexPath(row: LastpageNumber, section: 0), at: .centeredHorizontally, animated: false)
        thumbnailCollectionView.selectItem(at: IndexPath(row: LastpageNumber, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        bookCollectionView.isUserInteractionEnabled = true
        

    }
    
    func setupDesign(){

        view.addSubview(bookCollectionView)
        bookCollectionView.topAnchor.constraint(equalTo: view.topAnchor , constant: 0).isActive = true
        bookCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bookCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bookCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        setupTopBar()
        setupBottomViewDesign()
    }
    
    func setupBottomViewDesign(){
        
        view.addSubview(bottomView)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: 20).isActive = true
        #warning("width should handled progromaticly based on device size")
        bottomView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        
        bottomView.layer.cornerRadius = 20
        bottomView.makeDropShadow(shadowOffset: CGSize(width: 0, height: 0), opacity: 0.5, radius: 25)
        
        bottomView.addSubview(pageSlider)
        pageSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.62).isActive = true
        pageSlider.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        pageSlider.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor, constant: -35).isActive = true
        
        bottomView.addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: pageSlider.topAnchor, constant: -5).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 10).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        
        bottomView.addSubview(currentPageNumberLabel)
        currentPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor, constant: 0).isActive = true
        currentPageNumberLabel.rightAnchor.constraint(equalTo: pageSlider.leftAnchor, constant: -17).isActive = true
        
        bottomView.addSubview(comicPageNumberLabel)
        comicPageNumberLabel.centerYAnchor.constraint(equalTo: pageSlider.centerYAnchor, constant: 0).isActive = true
        comicPageNumberLabel.leftAnchor.constraint(equalTo: pageSlider.rightAnchor, constant: 17).isActive = true
        
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
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        topBar.addSubview(dismissButton)
        dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 20).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 27).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 27).isActive = true
        dismissButton.clipsToBounds = true
        
        
        
    }
    
    func addGestures() {
        
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(appearTapGestureTapped))
        upSwipeGesture.direction = .up
        bookCollectionView.addGestureRecognizer(upSwipeGesture)
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dissappearTapGestureTapped))
        downSwipeGesture.direction = .down
        thumbnailCollectionView.addGestureRecognizer(downSwipeGesture)
        
        let downSwipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(dissappearTapGestureTapped))
        downSwipeGesture2.direction = .down
        bookCollectionView.addGestureRecognizer(downSwipeGesture)
        
    }
    
    func updatePageSlider(with value: Int){
        pageSlider.setValue(Float(value), animated: true)
        currentPageNumberLabel.text = String(value)
    }
    
    @objc func sliderDidChanged(){
        let value = Int(pageSlider.value)
        currentPageNumberLabel.text = String(value)
        thumbnailCollectionView.scrollToItem(at: IndexPath(row: value - 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    @objc func sliderDidFinishedChanging(){
        let value = Int(pageSlider.value)
        thumbnailCollectionView.selectItem(at: IndexPath(row: value - 1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        bookCollectionView.scrollToItem(at: IndexPath(row: value - 1, section: 0), at: .centeredHorizontally, animated: true)
        
    }
    
    @objc func appearTapGestureTapped() {
        appearMenus(animated: true)
    }
    
    @objc func dissappearTapGestureTapped() {
        disappearMenus(animated: true)
    }
    
    func disappearMenus(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 0.0
                self.dismissButton.alpha = 0.0
                self.topBar.alpha = 0.0
                
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0.7
            }) { (_) in
                self.titleLabel.alpha = 0.0
                self.dismissButton.alpha = 0.0
                self.topBar.alpha = 0.0
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0.7
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
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
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
    
    
    @objc func closeTheVC(){
//        self.modalPresentationStyle = .fullScreen
        dismiss(animated: false, completion: nil)
        if let visibleCell = bookCollectionView.visibleCells.first {
            lastViewedPage = bookCollectionView.indexPath(for: visibleCell)?.row
            
            if let _ = comic {
                let defaults = UserDefaults.standard
                let id = comic!.id + "-lastViewedPage"
                defaults.set(lastViewedPage, forKey: id)
            }
        }
    }
    
    func getLastviewedPage() -> Int{
        let id = comic!.id + "-lastViewedPage"
        return UserDefaults.standard.integer(forKey: id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
       
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    


}

extension BookReaderVC: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comic?.pages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.restorationIdentifier == "thumbnail" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! thumbnailCell
            cell.comicPage  = comic?.pages[indexPath.row]
            cell.pageNumber = indexPath.row + 1
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! PageCell
            cell.comicPage  = comic?.pages[indexPath.row]
//            cell.pageNumber = indexPath.row
            return cell
        }
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.restorationIdentifier == "thumbnail" {
            return CGSize(width: collectionView.frame.height * 0.7, height: collectionView.frame.height)
        }else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.restorationIdentifier ==  "book" {
            if let visibleCell = bookCollectionView.visibleCells.first {
                if let currentIndex = bookCollectionView.indexPath(for: visibleCell) {
                    thumbnailCollectionView.selectItem(at: currentIndex, animated: true, scrollPosition: .centeredHorizontally)
                    updatePageSlider(with: currentIndex.row + 1)
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "book" {
            let pageCell = cell as? PageCell
            guard let scale = pageCell?.scrollView.minimumZoomScale else { return }
            if scale < 1.0 {
                pageCell?.scrollView.setZoomScale(scale, animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "thumbnail" {
            bookCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            thumbnailCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updatePageSlider(with: indexPath.row + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "thumbnail" {
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.restorationIdentifier != "thumbnail" {
//            let visibleCells = bookCollectionView.visibleCells
//            for cell in visibleCells {
//                print(bookCollectionView.indexPath(for: cell) ?? "not found")
//            }
//
////            if let index = bookCollectionView.indexPath(for: visibleCell) {
////                print(index)
////                thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
//////                thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
////            }
////        }
//        }
//    }
    
    
    
}


