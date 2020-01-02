//
//  ViewController.swift
//  wutComicReader
//
//  Created by Shayan on 5/31/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import ZIPFoundation
import UnrarKit
import CoreData

class LibraryVC: UIViewController {
    
    //MARK:- variables
    
    var bottomGradientImage : UIImageView?
    var comics : [Comic] = []
    var comicGroups : [String] = ["New Comics"]
    var collectionViewCellSize: CGSize?
    
    let appfileManager = AppFileManager()
    let comicExtractor = ComicExteractor()
    
    var editingMode = false {
        didSet{
            //            navigationItem.largeTitleDisplayMode =  editingMode ? .never : .always
            if editingMode {
                groupBarButton.title = "Group"
                deleteBarButton.title = "Delete"
                editBarButton.title = "Done"
                
            }else{
                groupBarButton.title = ""
                deleteBarButton.title = ""
                editBarButton.title = "edit"
                deleteBarButton.isEnabled = false
                groupBarButton.isEnabled = false
                
            }
            bookCollectionView.reloadData()
        }
        
    }
    
    var deviceIsLandscaped = UIDevice.current.orientation.isLandscape {
        didSet{
            updateCollectionViewLayoutBasedScreenSize()
        }
    }
    
    var selectedCell : [IndexPath] = [] {
        didSet{
            groupBarButton.isEnabled = selectedCell.count > 1
            deleteBarButton.isEnabled = !selectedCell.isEmpty
            print(selectedCell)
        }
    }
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var groupBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    
    
    
    //MARK:- Design functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //line below is could be wrong!
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
//            makeAppDirectory()
        }
        bookCollectionView.allowsMultipleSelection = true
        fetchComics()
//        print(comics)
        setUpDesigns()
        bookCollectionView.reloadData()
        
        print(NSHomeDirectory())
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        deviceIsLandscaped = UIDevice.current.orientation.isLandscape
    }
    
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        groupBarButton.title = ""
        deleteBarButton.title = ""
        
        makeCustomNavigationBar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        deviceIsLandscaped = UIDevice.current.orientation.isLandscape
    }
    
    
    
    func updateCollectionViewLayoutBasedScreenSize() {
        let deviceWidth = UIScreen.main.bounds.width
//        print("device width is : \(UIScreen.main.bounds.width)")
        if deviceWidth < 567 {
            collectionViewCellSize = CGSize(width: bookCollectionView.frame.width / 3.9, height: bookCollectionView.frame.width / 2.3)
        }else {
            collectionViewCellSize = CGSize(width: bookCollectionView.frame.width / 8.0, height: bookCollectionView.frame.width / 4.2)
        }
        #warning("configuration for ipad ??(if device with > 1000)")
        bookCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func makeBottomViewGradiant(){
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "gradient")
        
        view.addSubview(imageView)
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomGradientImage = imageView
    }
    
    //MARK:- actions
        
        @IBAction func unzipButtonTapped(_ sender: Any) {
            deleteAllComics()
            try? comicExtractor.extractUserComicsIntoComicDiractory()
            try? appfileManager.writeNewComicsOnCoreData()
            fetchComics()
            bookCollectionView.reloadData()
        }
        
        @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        }
        @IBAction func groupBarButtonTapped(_ sender: Any) {
            
            
            
            let alert = UIAlertController(title: "New Group Title", message: "enter the new group title", preferredStyle: .alert)
            alert.addTextField { (textfield) in
                textfield.text = ""
            }
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
    //            self.makingAnAppGroup(with: alert.textFields![0].text ?? "")
                self.selectedCell.removeAll()
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(okAction)
            present(alert , animated: true)
            
            bookCollectionView.reloadData()
            
            
        }
        
        @IBAction func editButtonTapped(_ sender: Any) {
            //        let numberOfSections = bookCollectionView.numberOfSections
            //        if !editingMode {
            //            for sectionNumber in 0 ... numberOfSections - 1 {
            //                for _ in 0 ... bookCollectionView.numberOfItems(inSection: sectionNumber) - 1 {
            bookCollectionView.selectItem(at: nil, animated: true, scrollPosition: [])
            //                }
            
            //            }
            //        }
            editingMode = !editingMode
            selectedCell.removeAll()
            bookCollectionView.reloadData()
        }
        
        @IBAction func fetchButtonTapped(_ sender: Any) {
            deleteAllComics()
        }
        
        
        @IBAction func closeSectionButtonTapped(_ sender: Any) {
            
        }
    
    //MARK:- top bar functions
    
//    func deleteSelectedComics() {
//
//        selectedCell.sort()
//        selectedCell.reverse()
//
//        for index in selectedCell {
//            comics[index.section].remove(at: index.row)
//        }
//
//        //removing empty section
//
//        for comic in comics {
//            if comic.isEmpty && comic != comics.first {
//                if let index = comics.firstIndex(of: comic) {
//                    comics.remove(at: index)
//                    sectionNames.remove(at: index)
//                }
//            }
//        }
//
//        //        bookCollectionView.deleteItems(at: selectedCell)
//        selectedCell.removeAll()
//        bookCollectionView.reloadData()
//    }
//
//
//    func makingAnAppGroup(with name: String){
//
//        if selectedCell.count < 2 { return }
//
//
//        //creating a group in array
//
//        var selectedComics : [Comic] = []
//
//        selectedCell.sort()
//        selectedCell.reverse()
//
//        for indexpath in selectedCell {
//            let cell = bookCollectionView.cellForItem(at: indexpath) as? BookCell
//            if let book = cell?.book {
//                comics[indexpath.section].remove(at: indexpath.row)
//                selectedComics.append(book)
//            }
//        }
//        comics.append(selectedComics)
//        sectionNames.append(name)
//
//        //removing empty sections that may generate after grouping
//
//        for comic in comics {
//            if comic.isEmpty {
//                if let index = comics.firstIndex(of: comic) {
//                    comics.remove(at: index)
//                    sectionNames.remove(at: index)
//                }
//            }
//        }
//
//        bookCollectionView.reloadData()
//
//
//    }
    
    func makeCustomNavigationBar(){
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    
    //MARK:- file functions
    
    func deleteAllComics(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let deletereq = NSFetchRequest<Comic>(entityName: "Comic")
        
        guard let comics = try? managedContext.fetch(deletereq) else { return }
        for comic in comics {
            managedContext.delete(comic)
        }
        try? managedContext.save()
    }
    
    func fetchComics(){
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
        fetchRequest.returnsObjectsAsFaults = false
        let sortingByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortingByName]
        
        do{
            comics = try managedContext.fetch(fetchRequest)
            bookCollectionView.reloadData()
        }catch let error{
            print("error happed while fetching from core Data: " + error.localizedDescription)
        }

    }
    
    func fetchGroupComics(){
//        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appdelegate.persistentContainer.viewContext
//        
//        let fetchRequest = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
////        let sortingByName = NSSortDescriptor(key: "name", ascending: true)
//        
//        do{
//        comicGroups = try managedContext.fetch(fetchRequest)
//        }catch let error{
//            print("error happed while fetching from core Data: " + error.localizedDescription)
//        }
    }
    
    
    
    
}

    //MARK:- collectionView functions

extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! LibraryCell
        cell.book = comics[indexPath.row]
        cell.selectionImageView.isHidden = !editingMode
        cell.setUpDesign()
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comicGroups.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath)
        let title = header.viewWithTag(101) as! UILabel
        title.text = comicGroups[indexPath.section]
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = collectionViewCellSize {
            return size
        }else{
            return CGSize(width: collectionView.frame.width / 3.9, height: collectionView.frame.width / 2.3)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if editingMode {
            if !selectedCell.contains(indexPath) {
                selectedCell.append(indexPath)
                
            }
        }else{
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
            readerVC.comic = comics[indexPath.row]
            //            NotificationCenter.default.post(name: NSNotification.Name(scrolltoLastViewedPageNN), object: nil)
            readerVC.modalPresentationStyle = .fullScreen
            present(readerVC , animated: false)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if editingMode{
            if selectedCell.contains(indexPath){
                guard let index = selectedCell.firstIndex(of: indexPath) else { return }
                selectedCell.remove(at: index)
            }
        }
    }
    
    
}
