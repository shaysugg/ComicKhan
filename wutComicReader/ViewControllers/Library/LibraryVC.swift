//
//  ViewController.swift
//  wutComicReader
//
//  Created by Shayan on 5/31/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import CoreData

class LibraryVC: UIViewController {
    
    //MARK:- variables
    
    var bottomGradientImage : UIImageView?
    var comicGroups : [ComicGroup] = [] {
        didSet{
            if let _ = emptyGroupsView {} else { designEmptyView() }
            emptyGroupsView.isHidden = !comicGroups.isEmpty
            
        }
    }
    var collectionViewCellSize: CGSize!
    
    let appfileManager = AppFileManager()
    let comicExtractor = ComicExteractor()
    
    var editingMode = false {
        didSet{
            if editingMode {
                navigationItem.leftBarButtonItems = [deleteBarButton , groupBarButton]
                editBarButton.title = "Done"
            }else{
                navigationItem.leftBarButtonItems = nil
                editBarButton.title = "Edit"
                deleteBarButton.isEnabled = false
                groupBarButton.isEnabled = false
                
            }
            refreshControll.isEnabled = !editingMode
            bookCollectionView.reloadData()
        }
        
    }
    
    var selectedComics : [Comic] = [] {
        didSet{
            groupBarButton.isEnabled = selectedComics.count > 1
            deleteBarButton.isEnabled = !selectedComics.isEmpty
        }
    }
    
//    var selectedSection: [Int] = []
    

    
    let refreshControll = UIRefreshControl()
    
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet var groupBarButton: UIBarButtonItem!
    @IBOutlet var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    
    lazy var redRefreshCircle: UIView = {
       let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    var emptyGroupsView: UIView!
    
    lazy var progressContainer : ProgressContainerView = {
        let progressConteiner = ProgressContainerView()
        progressConteiner.translatesAutoresizingMaskIntoConstraints = false
        return progressConteiner
    }()
    var progressContainerHideTopConstrait: NSLayoutConstraint!
    var progressContainerAppearedTopConstrait: NSLayoutConstraint!
    
    
    
    
    //MARK:- functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appLaunchedForFirstTime() {
            do {
                try appfileManager.makeAppDirectory()
            }catch{
                fatalError("can't crate app comic diractory")
            }
        }
        
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        fetchGroupComics()
        bookCollectionView.allowsMultipleSelection = true
        setUpDesigns()
        bookCollectionView.reloadData()
        setupPullToRefresh()
        comicExtractor.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGroupComics), name: .newGroupAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionViewAtIndex(_:)), name: .reloadLibraryAtIndex, object: nil)
        print(NSHomeDirectory())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appfileManager.didNewFileAddedToUserDiractory() {
             
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureCellSize(basedOn: UIScreen.main.traitCollection)
    }
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        navigationItem.leftBarButtonItems = nil
        
        makeCustomNavigationBar()
        setUpProgressBarDesign()
        bookCollectionView.backgroundColor = .appSystemBackground
        view.backgroundColor = .appSystemBackground
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
        refreshControll.tintColor = .clear
        refreshControll.subviews.first?.alpha = 0
        refreshControll.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .valueChanged)
    }
    
    func designEmptyView(){
        emptyGroupsView = UIView()
        emptyGroupsView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyLibrary")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Looks like you don’t have any comics here at this moment ..."
        label.font = UIFont(name: HelvetincaNeueFont.light.name, size: 20)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyViewWidth = view.bounds.width * (deviceType == .iPad ? 0.5 : 1)
        
        bookCollectionView.addSubview(emptyGroupsView)
        emptyGroupsView.widthAnchor.constraint(equalToConstant: emptyViewWidth).isActive = true
        emptyGroupsView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        emptyGroupsView.centerXAnchor.constraint(equalTo: bookCollectionView.centerXAnchor).isActive = true
        emptyGroupsView.centerYAnchor.constraint(equalTo: bookCollectionView.centerYAnchor).isActive = true

        
        emptyGroupsView.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: emptyGroupsView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: emptyGroupsView.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: emptyGroupsView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        emptyGroupsView.addSubview(label)
        label.leftAnchor.constraint(equalTo: emptyGroupsView.leftAnchor , constant: 15).isActive = true
        label.rightAnchor.constraint(equalTo: emptyGroupsView.rightAnchor , constant: -15).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        
        
        
        
    }
    
    func configureCellSize(basedOn traitcollection: UITraitCollection) {
        let h = traitCollection.horizontalSizeClass
        let v = traitCollection.verticalSizeClass
        
        let larg = view.bounds.width > view.bounds.height ? view.bounds.width : view.bounds.height
        let short = view.bounds.width > view.bounds.height ? view.bounds.height : view.bounds.width
        
        var collectionViewCellWidth: CGFloat {
            if h == .regular && v == .compact {
                return larg / 8
            }else if h == .compact && v == .regular {
                return short / 4
            }else if h == .compact && v == .compact {
                return larg / 6
            }else {
                return larg / 9
            }
        }
        
        collectionViewCellSize = CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth * 1.7)
    }
    
    @objc func reloadCollectionViewAtIndex(_ notification: NSNotification){
        guard let indexPath = notification.object as? IndexPath else { return }
        let cell = bookCollectionView.cellForItem(at: indexPath) as? LibraryCell
        cell?.updateProgressValue()
        print("indexPath: \(indexPath)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    
    //MARK:- actions
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        syncComics {
            self.fetchNewComics()
            self.bookCollectionView.reloadData()
            self.refreshControll.endRefreshing()
        }
        
    }
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        for comic in selectedComics where (comic.name != nil && comic.name != ""){
            do{
                try appfileManager.deleteFileInTheAppDiractory(withName: comic.name!)
                try appfileManager.deleteFileInTheUserDiractory(withName: comic.name!)
                appfileManager.deleteComicFromCoreData(withName: comic.name!)
                
            }catch let err {
                #warning("error handeling! of this part")
                print("remove comic error \(err.localizedDescription)")
            }
        }
        
        fetchGroupComics()
        bookCollectionView.reloadData()
        
    }
    
    @IBAction func groupBarButtonTapped(_ sender: Any) {
        let newGroupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        newGroupVC.comicsAboutToGroup = selectedComics
        present(newGroupVC , animated: true)
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
    
    private func makeEmptyView(appear isApear:Bool){
        bookCollectionView.isHidden = !isApear
        let emptyView = UIView()
        emptyView.backgroundColor = .appSystemBackground
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        if isApear{
            
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
    
    func fetchNewComics(){
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        var fetchedComics: [Comic] = []
        
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
        fetchRequest.returnsObjectsAsFaults = false
        let predict = NSPredicate(format: "ofComicGroup == nil || ofComicGroup.isForNewComics == true")
        fetchRequest.predicate = predict
        let sortingByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortingByName]
        
        let groupForNewComics = comicGroups.filter({
            return $0.isForNewComics
            }).first
        
        do{
            fetchedComics = try managedContext.fetch(fetchRequest)
        }catch let error{
            print("error happed while fetching from core Data: " + error.localizedDescription)
            return
        }
        
        if fetchedComics.isEmpty { return }
        
        if let group = groupForNewComics {
            group.comics = NSOrderedSet(array: fetchedComics)
            try? managedContext.save()
        }else{
            let group = createAGroupForNewComics()
            group?.comics = NSOrderedSet(array: fetchedComics)
            fetchGroupComics()
        }
        
        bookCollectionView.reloadData()
        
    }
    
    @objc func fetchGroupComics(){
        
        deleteEmptyGroups()
        selectedComics.removeAll()
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")

        do{
            comicGroups = try managedContext.fetch(fetchRequest)
            deleteEmptyGroups()
            bookCollectionView.reloadData()
        }catch let error{
            fatalError("error happed while fetching from core Data: " + error.localizedDescription)
        }
        
    }
    
    private func deleteEmptyGroups(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
       
        for group in comicGroups where group.comics?.count == 0 {
            managedContext.delete(group)
        }
        
        do{
            try managedContext.save()
        }catch let err {
            print("unable to save non empty comics: " + err.localizedDescription)
        }
        
        
        
    }
    
    private func createAGroupForNewComics() -> ComicGroup?{
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let newComicGroup = ComicGroup(context: managedContext)
        newComicGroup.name = "New Comics"
        newComicGroup.id = UUID()
        newComicGroup.isForNewComics = true
        
        do{
            try managedContext.save()
            return newComicGroup
        }catch let err {
            fatalError(err.localizedDescription)
            #warning("error handeling")
            return nil
        }
    }
    
    
    
    
}

