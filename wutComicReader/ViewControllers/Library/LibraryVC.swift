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
import Combine

var diractoryWatcher: DirectoryWatcher?


class LibraryVC: UIViewController {
    
    //MARK:- Variables
    
    private(set) var appfileManager: AppFileManager!
    private let comicExtractor = ComicExteractor()
    var dataService: DataService!
    
    var fetchResultController: NSFetchedResultsController<Comic>!
    var blockOperations = [BlockOperation]()
    
    var newFilesCount: Int?
    
    private(set) var collectionViewCellSize: CGSize!
    
    var editingMode = false
    
    let indexSelectionManager = IndexSelectionManager()
    var indexSelectionCancelabels = [Cancellable]()
    
    //MARK:- UI Variables
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var addComicsButton: UIBarButtonItem!
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
    var progressContainerInCopyingStateHeight: NSLayoutConstraint!
    var progressContainerInExtractingStateHeight: NSLayoutConstraint!
    var comicNameThatExtracting: String?
    
    
    var CHConstratis = [NSLayoutConstraint]()
    var RHConstratis = [NSLayoutConstraint]()
    
    
    lazy var cellFullSizeView: UIImageView = {
       let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var cellFullSizeConstraint = [NSLayoutConstraint]()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataService = DataService()
        appfileManager = AppFileManager(dataService: dataService)
        
        if appLaunchedForFirstTime() {
            do {
                try dataService.createGroupForNewComics()
                try appfileManager.makeAppDirectory()
                setAppDidLaunchedFlag()
                
            }catch let error {
                fatalError("Initialing Values was failed: " + error.localizedDescription)
            }
        }

        do {
            fetchResultController = try dataService.configureFetchResultController()
        }catch {
            showAlert(with: "Oh!", description: "there is a problem with fetching your comics")
        }
        
        setupDiractoryWatcher()
        didUserAddNewFilesWhileAppWasDeactive()
        
        fetchResultController.delegate = self
        
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        
        setUpDesigns()
        
        comicExtractor.delegate = self
        appfileManager.progressDelegate = self
        emptyGroupsView.delegate = self
        
        bookCollectionView.reloadData()
        bookCollectionView.allowsMultipleSelection = true
        
        setUpSelectedCellObservers()
         
        navigationItem.setRightBarButtonItems([infoButton], animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newGroupVCAddedANewGroup), name: .newGroupAboutToAdd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionViewAtIndex(_:)), name: .reloadLibraryAtIndex, object: nil)
        
        print(NSHomeDirectory())
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barTintColor = .appSystemBackground
        emptyGroupsView.isHidden = !(fetchResultController.fetchedObjects?.isEmpty ?? true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let _ = diractoryWatcher?.startWatching()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let _ = diractoryWatcher?.stopWatching()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        bookCollectionView.collectionViewLayout.invalidateLayout()
        layoutTrait(traitCollection: traitCollection)
        
    }
    
    func layoutTrait(traitCollection: UITraitCollection) {
        NSLayoutConstraint.deactivate(RHConstratis)
        NSLayoutConstraint.deactivate(CHConstratis)
        
        
        if traitCollection.horizontalSizeClass == .compact,
            traitCollection.verticalSizeClass == .regular {
            //for portrait phones
            NSLayoutConstraint.activate(CHConstratis)
        }else {
            NSLayoutConstraint.activate(RHConstratis)
        }
    }
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nil
        
        makeCustomNavigationBar()
        setUpProgressBarDesign()
        designEmptyView()
        layoutTrait(traitCollection: traitCollection)
        
        bookCollectionView.backgroundColor = .appSystemBackground
        view.backgroundColor = .appSystemBackground
        
        let infoImage = #imageLiteral(resourceName: "ic-actions-more-2").withRenderingMode(.alwaysTemplate)
        infoButton.image = infoImage
        
        let addComicsImage = #imageLiteral(resourceName: "ic-actions-add").withRenderingMode(.alwaysTemplate)
        addComicsButton.image = addComicsImage
        
        let deleteImage = #imageLiteral(resourceName: "ic-actions-trash").withRenderingMode(.alwaysTemplate)
        deleteBarButton.image = deleteImage
        
        let groupImage = #imageLiteral(resourceName: "group2").withRenderingMode(.alwaysTemplate)
        groupBarButton.image = groupImage
    }
    
    
    func designEmptyView(){

        bookCollectionView.addSubview(emptyGroupsView)
        emptyGroupsView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        emptyGroupsView.centerXAnchor.constraint(equalTo: bookCollectionView.centerXAnchor).isActive = true
        emptyGroupsView.centerYAnchor.constraint(equalTo: bookCollectionView.centerYAnchor).isActive = true
        
        RHConstratis.append(
            emptyGroupsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        )
        CHConstratis.append(
            emptyGroupsView.widthAnchor.constraint(equalTo: view.widthAnchor)
        )
        
    }
    
        
    //MARK:- Collection View Functions
    
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
    
    private func setUpSelectedCellObservers() {
        
        let barButtonIsEnabled = indexSelectionManager.publisher.tryMap{!$0.isEmpty}.replaceError(with: false)
        
        indexSelectionCancelabels = [
            barButtonIsEnabled.assign(to: \.isEnabled, on: groupBarButton),
            barButtonIsEnabled.assign(to: \.isEnabled, on: deleteBarButton)
        ]
    }
    
    
    //MARK:- actions
    @IBAction func addComicsButtonTapped(_ sender: Any) {
        let documentVC = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentVC.allowsMultipleSelection = true
        documentVC.delegate = self
        
        present(documentVC, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        for indexPath in indexSelectionManager.indexes{
            let comic = fetchResultController.object(at: indexPath)
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
        indexSelectionManager.removeAll()
        
    }

    @IBAction func groupBarButtonTapped(_ sender: Any) {
        let newGroupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        newGroupVC.comicsAboutToGroup = indexSelectionManager.indexes.map {fetchResultController.object(at: $0)}
        newGroupVC.dataService = dataService
        present(newGroupVC , animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        bookCollectionView.selectItem(at: nil, animated: true, scrollPosition: [])
        editingMode = !editingMode
        indexSelectionManager.removeAll()
        updateNavBarWhenEditingChanged()
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
            navigationItem.setRightBarButtonItems([deleteBarButton , groupBarButton , infoButton], animated: true)
            infoButton.isEnabled = false
            addComicsButton.isEnabled = false
            infoButton.tintColor = view.backgroundColor
            editBarButton.title = "Done"
        }else{
            navigationItem.setRightBarButtonItems([infoButton], animated: true)
            infoButton.isEnabled = true
            addComicsButton.isEnabled = true
            infoButton.tintColor = .appSecondaryLabel
            editBarButton.title = "Edit"
            deleteBarButton.isEnabled = false
            groupBarButton.isEnabled = false
            
        }
    }
    
    
    //MARK:- file functions
    
    @objc private func newGroupVCAddedANewGroup() {
        indexSelectionManager.removeAll()
    }
    
    // if app killed or terminated in background when did open again
    // diractory watcher not gonna work again so we check with below function
    // that is user diractory has file in it or not
    func didUserAddNewFilesWhileAppWasDeactive() {
        if let files = appfileManager.filesInUserDiractory(),
            !files.isEmpty {
            newFilesCount = files.count
            extractAndWriteNewComicsOnCoreData(files)
        }
    }
    
    func setupDiractoryWatcher() {
        
        diractoryWatcher = DirectoryWatcher.watch(URL.userDiractory)
        
        diractoryWatcher?.onNewFiles = { [weak self] newfiles in
            self?.newFilesCount = newfiles.count
            self?.extractAndWriteNewComicsOnCoreData(newfiles)
        }
    
    }
    
    
    func extractAndWriteNewComicsOnCoreData(_ newfiles: [URL]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
                //if app got killed in background
                if let name = self?.comicNameThatExtracting {
                    try? self?.dataService.deleteComicFromCoreData(withName: name)
                    try? self?.appfileManager.deleteFileInTheAppDiractory(withName: name)
                }
            })
            
            
            do{
                /// - Q: how it realize that extracting is finished and should write new comics into coreData ???
                
            self?.comicExtractor.extractUserComicsIntoComicDiractory()
            try self?.appfileManager.writeNewComicsOnCoreData()
                
                for newfile in newfiles {
                    //if this one fail there gonna be aloooots of problems!
                    try? FileManager.default.removeItem(at: newfile)
                }
                
                if taskID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(taskID)
                }
                
            }catch{
                DispatchQueue.main.async {
                    self?.showAlert(with: "OH!",
                    description: "there was a problem with your comic file Extraction, please try again.")
                    self?.removeProgressView()
                }
                
                if taskID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(taskID)
                }
            }
        }
    }
    
    
}

