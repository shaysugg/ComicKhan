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
    //    var comics : [Comic] = []
    var comicGroups : [ComicGroup] = [] {
        didSet{
            print(comicGroups)
        }
    }
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
                editBarButton.title = "Edit"
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
    
    var selectedComics : [Comic] = [] {
        didSet{
            groupBarButton.isEnabled = selectedComics.count > 1
            deleteBarButton.isEnabled = !selectedComics.isEmpty
            print(selectedComics)
        }
    }
    
    let refreshControll = UIRefreshControl()
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var groupBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    
    
    
    //MARK:- functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appLaunchedForFirstTime() {
            do {
                try appfileManager.makeAppDirectory()
            }catch{
                fatalError("can't crate app comic diractory")
            }
            createAComicGroup(with: "New Comics")
        }
        fetchGroupComics()
        bookCollectionView.allowsMultipleSelection = true
        fetchComics()
        setUpDesigns()
        bookCollectionView.reloadData()
        setupPullToRefresh()
        
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
    
    func setupPullToRefresh(){
        bookCollectionView.refreshControl = refreshControll
        
        refreshControll.addTarget(self, action: #selector(unzipButtonTapped(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    
    //MARK:- actions
    
    @IBAction func unzipButtonTapped(_ sender: Any) {
        syncComics {
            self.fetchComics()
            self.bookCollectionView.reloadData()
            self.refreshControll.endRefreshing()
        }
        
        
    }
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        for comic in selectedComics {
            do{
                print(comic.name)
                try appfileManager.deleteFileInTheAppDiractory(withName: comic.name ?? "")
                try appfileManager.deleteFileInTheUserDiractory(withName: comic.name ?? "")
                appfileManager.deleteComicFromCoreData(withName: comic.name ?? "")
            }catch {
                #warning("error handeling! of this part")
            }
        }
        
        fetchGroupComics()
        bookCollectionView.reloadData()
        
    }
    
    @IBAction func groupBarButtonTapped(_ sender: Any) {
        
        var nameTextField: UITextField?
        
        let alert = UIAlertController(title: "New Group Title", message: "enter the new group title", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.text = ""
            nameTextField = textfield
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            self.createAComicGroup(with: nameTextField?.text ?? "")
            self.selectedComics.removeAll()
            
            alert.dismiss(animated: true, completion: {
                
                self.fetchGroupComics()
                self.bookCollectionView.reloadData()
                
            })
        }
        
        alert.addAction(okAction)
        present(alert , animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        bookCollectionView.selectItem(at: nil, animated: true, scrollPosition: [])
        editingMode = !editingMode
        selectedComics.removeAll()
        bookCollectionView.reloadData()
    }
    
    @IBAction func fetchButtonTapped(_ sender: Any) {
        deleteAllComics()
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
    
    func createAComicGroup(with name: String){
        
        if selectedComics.count < 2 && name != "New Comics" { return }
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let newComicGroup = ComicGroup(context: managedContext)
        newComicGroup.name = name
        newComicGroup.id = UUID()
        newComicGroup.comics = NSOrderedSet(array: selectedComics)
        
        for comic in selectedComics {
            comic.ofComicGroup = newComicGroup
        }
        
        do{
            try managedContext.save()
        }catch{
            print("error while creating a comic group")
        }
        
        
    }
    
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
    
    func syncComics(completed: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            self.comicExtractor.extractUserComicsIntoComicDiractory()
            self.appfileManager.writeNewComicsOnCoreData()
            self.appfileManager.syncRemovedComicsInUserDiracory()
            DispatchQueue.main.async {
                completed()
            }
        }
    }
    
    func fetchComics(){
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
                fetchRequest.returnsObjectsAsFaults = false
        //        let sortingByName = NSSortDescriptor(key: "name", ascending: true)
        //        fetchRequest.sortDescriptors = [sortingByName]
        
        do{
            let comics = try managedContext.fetch(fetchRequest)
            comicGroups[0].comics = NSOrderedSet(array: comics)
            print(comics)
            bookCollectionView.reloadData()
        }catch let error{
            print("error happed while fetching from core Data: " + error.localizedDescription)
        }
        
    }
    
    func fetchGroupComics(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
        
        do{
            comicGroups = try managedContext.fetch(fetchRequest)
        }catch let error{
            print("error happed while fetching from core Data: " + error.localizedDescription)
        }
    }
    
    
    
    
}

//MARK:- collectionView functions

extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comicGroups[section].comics?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! LibraryCell
        cell.book = comicGroups[indexPath.section].comics?[indexPath.row] as? Comic
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
        title.text = comicGroups[indexPath.section].name
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
        
        let selectedComic = comicGroups[indexPath.section].comics?[indexPath.row] as! Comic
        
        if editingMode {
            if !selectedComics.contains(selectedComic) {
                selectedComics.append(selectedComic)
                
            }
        }else{
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
            readerVC.comic = selectedComic
            readerVC.modalPresentationStyle = .fullScreen
            present(readerVC , animated: false)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if editingMode{
            
            let deSelectedComic = comicGroups[indexPath.section].comics?[indexPath.row] as! Comic
            
            if selectedComics.contains(deSelectedComic){
                guard let comic = selectedComics.firstIndex(of: deSelectedComic) else { return }
                selectedComics.remove(at: comic)
            }
        }
    }
    
    
}
