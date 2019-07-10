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
    
    var comic : Comic?
    var menusAreAppeard: Bool = false
    
    var previousCell : thumbnailCell?
    
    var bookCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionview.isPagingEnabled = true
        collectionview.register(pageCell.self, forCellWithReuseIdentifier: "pageCell")
        collectionview.backgroundColor = .black
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.tag = 101
        return collectionview
    }()
    
    
    var thumbnailCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        collectionView.register(thumbnailCell.self, forCellWithReuseIdentifier: "thumbnailCell")
        collectionView.restorationIdentifier = "thumbnail"
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var closeButton : UIButton = {
        let button = UIButton()
        button.setTitle("close", for: .normal)
        button.addTarget(self, action: #selector(closeTheVC), for: .touchUpInside)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var topNavigationMenu : UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 340, height: 44))
        let navTitle = UINavigationItem(title: "Reader")
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTheVC))
        navTitle.leftBarButtonItems = [closeButton]
        navBar.tintColor = .lightGray
        navBar.barTintColor = .black
        navBar.isTranslucent = false
        navBar.barStyle = UIBarStyle.black
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        navTitle.titleView?.tintColor = .lightGray
//        navBar.setItems([navTitle], animated: false)
        return navBar
    }()
    
    var borderView : UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    var bottomView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var appearingMenuTapGesture : UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(appearTapGestureTapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.cancelsTouchesInView = true
        tapGesture.delaysTouchesBegan = true
        return tapGesture
    }()
    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        disappearMenus(animated: false)
        
        let navTitle = UINavigationItem(title: comic?.name ?? "")
        topNavigationMenu.setItems([navTitle], animated: false)
        let closeButton = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(closeTheVC))
        navTitle.leftBarButtonItems = [closeButton]
        
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
        
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
       
    }
    
 
    
    func setupDesign(){
        
        view.backgroundColor = .black
        
        view.addSubview(bookCollectionView)
        bookCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: 30).isActive = true
        bookCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bookCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        bookCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        bookCollectionView.addGestureRecognizer(appearingMenuTapGesture)
        
        
        view.addSubview(topNavigationMenu)
        topNavigationMenu.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        topNavigationMenu.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        topNavigationMenu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topNavigationMenu.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let topBorderView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.backgroundColor = .lightGray
        
        topNavigationMenu.addSubview(topBorderView)
        topBorderView.leftAnchor.constraint(equalTo: topNavigationMenu.leftAnchor).isActive = true
        topBorderView.rightAnchor.constraint(equalTo: topNavigationMenu.rightAnchor).isActive = true
        topBorderView.bottomAnchor.constraint(equalTo: topNavigationMenu.bottomAnchor, constant: -5).isActive = true
        topBorderView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        view.addSubview(bottomView)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.35).isActive = true
        
        bottomView.addSubview(thumbnailCollectionView)
        thumbnailCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        thumbnailCollectionView.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        thumbnailCollectionView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 10).isActive = true
        thumbnailCollectionView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        
        let bottomBorderView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.backgroundColor = .lightGray
        
        bottomView.addSubview(bottomBorderView)
        bottomBorderView.leftAnchor.constraint(equalTo: bottomView.leftAnchor).isActive = true
        bottomBorderView.rightAnchor.constraint(equalTo: bottomView.rightAnchor).isActive = true
        bottomBorderView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        bottomBorderView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        
    }
    
    @objc func appearTapGestureTapped() {
        menusAreAppeard ? disappearMenus(animated: true) : appearMenus(animated: true)
    }
    
    func disappearMenus(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y:  -self.topNavigationMenu.frame.height)
                self.topNavigationMenu.alpha = 0
                
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0
            }) { (_) in
                self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y:  -self.topNavigationMenu.frame.height)
                self.topNavigationMenu.alpha = 0
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
                self.bottomView.alpha = 0
                self.menusAreAppeard = false
            }
        }else{
            self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y:  -self.topNavigationMenu.frame.height)
            self.topNavigationMenu.alpha = 0
            
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
            self.bottomView.alpha = 0
            menusAreAppeard = false
        }
        
    }
    
    func appearMenus(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y:  0)
                self.topNavigationMenu.alpha = 1
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomView.alpha = 1
            }) { (_) in
                self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y:  0)
                self.topNavigationMenu.alpha = 1
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomView.alpha = 1
                self.menusAreAppeard = true
            }
        }else{
            self.topNavigationMenu.transform = CGAffineTransform(translationX: 0, y: 0)
            self.topNavigationMenu.alpha = 1
            
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.bottomView.alpha = 1
            menusAreAppeard = true
        }
        
    }
    
    
    @objc func closeTheVC(){
        dismiss(animated: true, completion: nil)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! pageCell
            cell.comicPage  = comic?.pages[indexPath.row]
            cell.pageNumber = indexPath.row
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
//        print(scrollView.superview?.restorationIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "thumbnail" {
            let bookCollectionView = view.viewWithTag(101) as! UICollectionView
            bookCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "thumbnail" {
        }
    }
    
    
}



