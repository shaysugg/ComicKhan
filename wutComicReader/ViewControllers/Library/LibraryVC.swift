//
//  ViewController.swift
//  wutComicReader
//
//  Created by Shayan on 5/31/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import UIKit
import DirectoryWatcher
import CoreData

class LibraryVC: UIViewController {
    
    //MARK:- Variables
    
    var appfileManager: AppFileManager!
    let comicExtractor = ComicExteractor()
    var dataService: DataService!
    var diractoryWatcher: DirectoryWatcher?
    
    var fetchResultController: NSFetchedResultsController<Comic>!
    var blockOperations = [BlockOperation]()
    
    var newFilesCount: Int?
    
    var collectionViewCellSize: CGSize!
    
    
    
    var editingMode = false {
        didSet{
            updateNavBarWhenEditingChanged()
            refreshButton.isEnabled = !editingMode
        }
        
    }
    
    var selectedComics : [Comic] = [] {
        didSet{
            groupBarButton.isEnabled = selectedComics.count > 0
            deleteBarButton.isEnabled = !selectedComics.isEmpty
        }
    }
    var selectedComicsIndexPaths : [IndexPath] = []
    
    //MARK:- UI Variables
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var infoButton: UIBarButtonItem!
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
    
    lazy var emptyGroupsView: EmptyGroupView = {
       let view = EmptyGroupView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var progressContainer : ProgressContainerView = {
        let progressConteiner = ProgressContainerView()
        progressConteiner.isHidden = true
        progressConteiner.translatesAutoresizingMaskIntoConstraints = false
        return progressConteiner
    }()
    var progressContainerHideBottomConstrait: NSLayoutConstraint!
    var progressContainerAppearedBottomConstrait: NSLayoutConstraint!
    var comicNameThatExtracting: String?
    
    
    lazy var cellFullSizeView: UIImageView = {
       let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var cellFullSizeConstraint = [NSLayoutConstraint]()
    
    
    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataService = DataService()
        
        if appLaunchedForFirstTime() {
            do {
                try dataService.createGroupForNewComics()
            }catch {
                fatalError("new comic group creation failed")
            }
        }
        
        
        appfileManager = AppFileManager(dataService: dataService)
        
        if appLaunchedForFirstTime() {
            do {
                try appfileManager.makeAppDirectory()
            }catch{
                fatalError("can't crate app comic diractory")
            }
        }
        

        do {
            fetchResultController = try dataService.configureFetchResultController()
        }catch {
            showAlert(with: "Oh!", description: "there is a problem with fetching your comics")
        }
        
        setupDiractoryWatcher()
        
        fetchResultController.delegate = self
        
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        
        setUpDesigns()
        bookCollectionView.reloadData()
        comicExtractor.delegate = self
        emptyGroupsView.delegate = self
        bookCollectionView.allowsMultipleSelection = true
         
        navigationItem.setLeftBarButtonItems([infoButton], animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newGroupVCAddedANewGroup), name: .newGroupAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionViewAtIndex(_:)), name: .reloadLibraryAtIndex, object: nil)
        
        print(NSHomeDirectory())
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        refreshUIIfNewComicAdded()
        let _ = diractoryWatcher?.startWatching()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let _ = diractoryWatcher?.stopWatching()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        bookCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        navigationItem.leftBarButtonItems = nil
        
        makeCustomNavigationBar()
        setUpProgressBarDesign()
        designEmptyView()
        bookCollectionView.backgroundColor = .appSystemBackground
        view.backgroundColor = .appSystemBackground
    }
    
    
    func designEmptyView(){
        let emptyViewWidth = view.bounds.width * (deviceType == .iPad ? 0.5 : 1)

        bookCollectionView.addSubview(emptyGroupsView)
        emptyGroupsView.widthAnchor.constraint(equalToConstant: emptyViewWidth).isActive = true
        emptyGroupsView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        emptyGroupsView.centerXAnchor.constraint(equalTo: bookCollectionView.centerXAnchor).isActive = true
        emptyGroupsView.centerYAnchor.constraint(equalTo: bookCollectionView.centerYAnchor).isActive = true
        
        
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barTintColor = .appSystemBackground
        emptyGroupsView.isHidden = !(fetchResultController.fetchedObjects?.isEmpty ?? true)
        
    }
    
    func setupDiractoryWatcher() {
        
        diractoryWatcher = DirectoryWatcher.watch(URL.userDiractory)
        
        diractoryWatcher?.onNewFiles = { [weak self] newfiles in
            self?.newFilesCount = newfiles.count
            DispatchQueue.global(qos: .background).async {
                
                let taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
                    //if app got killed in background
                    if let name = self?.comicNameThatExtracting {
                        try? self?.dataService.deleteComicFromCoreData(withName: name)
                        try? self?.appfileManager.deleteFileInTheAppDiractory(withName: name)
                    }
                })
                
                
                do{
                self?.comicExtractor.extractUserComicsIntoComicDiractory()
                try self?.appfileManager.writeNewComicsOnCoreData()
                    try? self?.fetchResultController.performFetch()
                    for newfile in newfiles {
                        try? FileManager.default.removeItem(at: newfile)
                    }
                    
                    if taskID != UIBackgroundTaskIdentifier.invalid {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                    
                }catch{
                    DispatchQueue.main.async {
                        self?.showAlert(with: "OH!",
                        description: "there was a problem with your comic file Extraction, please try again.")
                    }
                    
                    if taskID != UIBackgroundTaskIdentifier.invalid {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                }
            }
        }
    
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    
    //MARK:- actions
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        let taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            //if app got killed in background
            if let name = self?.comicNameThatExtracting {
                do {
                try self?.dataService.deleteComicFromCoreData(withName: name)
                try self?.appfileManager.deleteFileInTheAppDiractory(withName: name)
                }catch {
                    #warning("error handeling")
                }
            }
        })
        syncComics { [weak self] in
            
            self?.refreshButton.image = UIImage(named: "refresh")
         
            if taskID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(taskID)
            }
        }
        
        
    }
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        for comic in selectedComics{
            if let comicName = comic.name,
                comicName != "" {
                do{
                    try dataService.deleteComicFromCoreData(withName: comicName)
                    try appfileManager.deleteFileInTheAppDiractory(withName: comicName)
                    
                }catch {
                    showAlert(with: "Oh!", description: "There is a problem with removing your comics")
                }
            }
        }
        
        selectedComics.removeAll()
        selectedComicsIndexPaths.removeAll()
        
    }

    @IBAction func groupBarButtonTapped(_ sender: Any) {
        let newGroupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        newGroupVC.comicsAboutToGroup = selectedComics
        newGroupVC.dataService = dataService
        present(newGroupVC , animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        bookCollectionView.selectItem(at: nil, animated: true, scrollPosition: [])
        editingMode = !editingMode
        selectedComics.removeAll()
        selectedComicsIndexPaths.removeAll()
        bookCollectionView.reloadData()
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        let infoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoVC") as! InfoVC
        navigationController?.pushViewController(infoVC, animated: true)
    }
    
    
    
    
    //MARK:- Top bar functions
    
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
        navigationBar?.barTintColor = .appSystemBackground
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = nil
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    func updateNavBarWhenEditingChanged() {
        if editingMode {
            navigationItem.setLeftBarButtonItems([deleteBarButton , groupBarButton , infoButton], animated: true)
            infoButton.isEnabled = false
            infoButton.tintColor = view.backgroundColor
            editBarButton.title = "Done"
        }else{
            navigationItem.setLeftBarButtonItems([infoButton], animated: true)
            infoButton.isEnabled = true
            infoButton.tintColor = .appSecondaryLabel
            editBarButton.title = "Edit"
            deleteBarButton.isEnabled = false
            groupBarButton.isEnabled = false
            
        }
    }
    
    
    //MARK:- file functions
    
    func refreshUIIfNewComicAdded() {
        if appfileManager.didUserDiractoryChanged() && progressContainer.isHidden {
        refreshButton.image = UIImage(named: "refreshHighlited")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    func syncComics(completed: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            do{
            self.comicExtractor.extractUserComicsIntoComicDiractory()
            try self.appfileManager.writeNewComicsOnCoreData()
            self.appfileManager.syncRemovedComicsInUserDiracory()
            DispatchQueue.main.async {
                completed()
                
            }
            }catch{
                self.showAlert(with: "OH!", description: "there was a problem with your comic file Extraction, please try again.")
            }
        }
    }
    
    @objc private func newGroupVCAddedANewGroup() {
        selectedComics.removeAll()
        selectedComicsIndexPaths.removeAll()
        
    }
    
    
    
    
}

