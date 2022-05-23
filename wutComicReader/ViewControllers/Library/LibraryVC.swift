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
    
    let appfileManager: AppFileManager!
    private(set) var comicExtractor: ComicExteractor
    private(set) var dataService: DataService
    
    let fetchResultController: NSFetchedResultsController<Comic>
    var blockOperations = [BlockOperation]()
    
    private(set) var collectionViewCellSize: CGSize!
    
    var editingMode = false
    
    var newComicsErrorsDescription = ""
    
    let indexSelectionManager = IndexSelectionManager()
    var indexSelectionCancelabels = [Cancellable]()
    
    //MARK:- UI Variables
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
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
    
    required init?(coder: NSCoder) {
        self.appfileManager = Cores.main.appfileManager
        self.comicExtractor = Cores.main.extractor
        self.dataService = Cores.main.dataService
        fetchResultController = try! dataService.configureFetchResultController()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDiractoryWatcher()
        didUserAddNewFilesWhileAppWasDeactive()
        
        configureCellSize(basedOn: UIScreen.main.traitCollection)
        setUpDesigns()
        
        setupDelegates()
        
        setUpNavigationButtons()
        
        setupNotificationCenterObservers()
        
        bookCollectionView.allowsMultipleSelection = true
        
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
            emptyGroupsView.designforportrait()
        }else {
            NSLayoutConstraint.activate(RHConstratis)
            emptyGroupsView.designForLandscape()
        }
    }
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nil
        
        designEmptyView()
        setUpProgressBarDesign()
        layoutTrait(traitCollection: traitCollection)
        
        bookCollectionView.backgroundColor = .appSystemBackground
        view.backgroundColor = .appSystemBackground
        
        let infoImage = #imageLiteral(resourceName: "ic-actions-more-1").withRenderingMode(.alwaysTemplate)
        infoButton.image = infoImage
        
        let deleteImage = #imageLiteral(resourceName: "ic-actions-trash").withRenderingMode(.alwaysTemplate)
        deleteBarButton.image = deleteImage
        
        let groupImage = #imageLiteral(resourceName: "group2").withRenderingMode(.alwaysTemplate)
        groupBarButton.image = groupImage
    }
    
    
    func designEmptyView(){

        view.addSubview(emptyGroupsView)
        
        emptyGroupsView.centerXAnchor.constraint(equalTo: bookCollectionView.centerXAnchor).isActive = true
        emptyGroupsView.centerYAnchor.constraint(equalTo: bookCollectionView.centerYAnchor).isActive = true
        
        RHConstratis.append(contentsOf: [
            emptyGroupsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            emptyGroupsView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        CHConstratis.append(
            emptyGroupsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        )
        
    }
    
    private func setupDelegates() {
        fetchResultController.delegate = self
        comicExtractor.delegate = self
        comicExtractor.errorDelegate = self
        appfileManager.progressDelegate = self
        appfileManager.errorDelegate = self
        emptyGroupsView.delegate = self
    }
    
    private func setupNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(newGroupVCAddedANewGroup), name: .newGroupAboutToAdd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionViewAtIndex(_:)), name: .reloadLibraryAtIndex, object: nil)
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
        collectionViewCellSize = CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth * 1.53)
    }
    
    @objc func reloadCollectionViewAtIndex(_ notification: NSNotification){
        guard let indexPath = notification.object as? IndexPath else { return }
        let cell = bookCollectionView.cellForItem(at: indexPath) as? LibraryCell
        cell?.updateProgressValue()
        
    }
    
    private func setUpNavigationButtons() {
        
        navigationItem.setRightBarButtonItems([addComicsButton , editBarButton], animated: true)
        navigationItem.setLeftBarButtonItems([infoButton], animated: true)
        
        let barButtonIsEnabled = indexSelectionManager.publisher.tryMap{!$0.isEmpty}.replaceError(with: false)
        
        indexSelectionCancelabels = [
            barButtonIsEnabled.assign(to: \.isEnabled, on: groupBarButton),
            barButtonIsEnabled.assign(to: \.isEnabled, on: deleteBarButton)
        ]
    }
    
    
    //MARK:- actions
    @IBAction func addComicsButtonTapped(_ sender: Any) {
        presentDocumentPicker()
        
        
    }
    
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        //if we don't sorted high to low then we have a crash
        let lowToHighIndexes = indexSelectionManager.indexes.sorted()
        let highToLowIndexes = lowToHighIndexes.reversed()
        
        for indexPath in highToLowIndexes{
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
        present(infoVC, animated: true)
    }
    
    
    
    
    //MARK:- Top bar functions
    
    func updateNavBarWhenEditingChanged() {
        if editingMode {
//            navigationItem.setRightBarButtonItems([deleteBarButton , groupBarButton , infoButton], animated: true)
            //            navigationItem.setLeftBarButtonItems([editBarButton], animated: true)
            bottomToolbar.isHidden = false
            bottomToolbar.alpha = 0
            
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 1
            } completion: { (_) in
                
            }
            
            
            
            bottomToolbar.isHidden = false
            //            infoButton.isEnabled = false
            addComicsButton.isEnabled = false
//            infoButton.tintColor = .clear
            editBarButton.title = "Done"
            editBarButton.style = .done
        }else{
//            navigationItem.setRightBarButtonItems([editBarButton], animated: true)
//            navigationItem.setLeftBarButtonItems([infoButton], animated: true)
            
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 0
            } completion: { (_) in
                self.bottomToolbar.isHidden = true
            }
            
            
//            infoButton.isEnabled = true
            addComicsButton.isEnabled = true
//            infoButton.tintColor = addComicsButton.tintColor
            editBarButton.title = "Edit"
            editBarButton.style = .plain
//            deleteBarButton.isEnabled = false
//            groupBarButton.isEnabled = false
            
        }
    }
    
    
    //MARK:- file functions
    
    func presentDocumentPicker() {
        let documentPickerVC: UIDocumentPickerViewController!
        
        if #available(iOS 14.0, *) {
            documentPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [.directory, .pdf, .init(exportedAs: "com.wutup.comic")], asCopy: true)
        } else {
            documentPickerVC = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        }
        documentPickerVC.allowsMultipleSelection = true
        documentPickerVC.delegate = self
        
        present(documentPickerVC, animated: true, completion: nil)
    }
    
    @objc private func newGroupVCAddedANewGroup() {
        indexSelectionManager.removeAll()
    }
    
    // if app killed or terminated in background when did open again
    // diractory watcher not gonna work again so we check with below function
    // that is user diractory has file in it or not
    func didUserAddNewFilesWhileAppWasDeactive() {
        if let files = appfileManager.filesInUserDiractory(),
            !files.isEmpty {
            extractAndWriteNewComicsOnCoreData()
        }
    }
    
    func setupDiractoryWatcher() {
        
        diractoryWatcher = DirectoryWatcher.watch(URL.userDiractory)
        
        diractoryWatcher?.onNewFiles = { [weak self] _ in
            self?.extractAndWriteNewComicsOnCoreData()
        }
    
    }
    
    
    func extractAndWriteNewComicsOnCoreData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
                //if app got killed in background
                if let name = self?.comicNameThatExtracting {
                    try? self?.dataService.deleteComicFromCoreData(withName: name)
                    try? self?.appfileManager.deleteFileInTheAppDiractory(withName: name)
                }
            })
            
            
            
            /// - Q: how it realize that extracting is finished and should write new comics into coreData ???
            
            self?.comicExtractor.extractUserComicsIntoComicDiractory()
            self?.appfileManager.writeNewComicsOnCoreData()
            try? self?.appfileManager.deleteAllUserDirectoryContent()
            DispatchQueue.main.async { self?.showExtractionErrorsIfExist() }
            
            
            if taskID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(taskID)
            }
        }
    }
    
    
}

#if DEBUG
extension LibraryVC {
    func setupForTes(comicExtracror: ComicExteractor? = nil, dataService: DataService? = nil) {
        if let comicExtracror = comicExtracror {
            self.comicExtractor = comicExtracror
        }
        if let dataService = dataService {
            self.dataService = dataService
        }
    }
}
#endif
