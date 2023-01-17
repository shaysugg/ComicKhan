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
    
    //MARK: Variables
    
    let appfileManager: AppFileManager!
    private(set) var comicExtractor: ComicExteractor
    private(set) var dataService: DataService
    
    let fetchResultController: NSFetchedResultsController<Comic>
    private var fetchResultHandler: LibraryFetchResultControllerHandler!
    
    private(set) var libraryCellSize: CGSize!
    
    var editingMode = false
    
    var newComicsErrorsDescription = ""
    
    let indexSelectionManager = IndexSelectionManager()
    private var cancelabels = [AnyCancellable]()
    private var fetchResultControllerHandler: NSFetchedResultsControllerDelegate!
    
    //MARK: UI Variables
    
    
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

    
    
    //MARK: Functions
    
    required init?(coder: NSCoder) {
        self.appfileManager = Cores.main.appfileManager
        self.comicExtractor = Cores.main.extractor
        self.dataService = Cores.main.dataService
        self.fetchResultController = try! dataService.configureFetchResultController()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchResultHandler = LibraryFetchResultControllerHandler(fetchResultController: fetchResultController,
                                                                      collectionView: bookCollectionView)
        
        setupDiractoryWatcher()
        didUserAddNewFilesWhileAppWasDeactive()
        libraryCellSize = configureCellSize(showNames: AppState.main.showComicNames)
        setUpDesigns()
        setupDelegates()
        setUpShowingComicNames()
        setUpNavigationButtons()
        
        bookCollectionView.allowsMultipleSelection = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barTintColor = .appBackground
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
        libraryCellSize = configureCellSize(showNames: AppState.main.showComicNames)
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
        
        bookCollectionView.backgroundColor = .appBackground
        view.backgroundColor = .appBackground
        
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
        fetchResultHandler.delegate = self
        comicExtractor.delegate = self
        comicExtractor.errorDelegate = self
        appfileManager.progressDelegate = self
        appfileManager.errorDelegate = self
        emptyGroupsView.delegate = self
    }
    
    private func setUpShowingComicNames() {
        AppState.main.$showComicNames.sink { [weak self] show in
            
            guard let self = self else { return }
            self.libraryCellSize = self.configureCellSize(showNames: show!)
            self.bookCollectionView.collectionViewLayout.invalidateLayout()
            self.bookCollectionView.reloadData()
        }.store(in: &cancelabels)
    }
    
    //MARK: Collection View Functions
    
    func configureCellSize(showNames: Bool) -> CGSize {
        let h = traitCollection.horizontalSizeClass
        let v = traitCollection.verticalSizeClass
        
        let larg = view.bounds.width > view.bounds.height ? view.bounds.width : view.bounds.height
        let short = view.bounds.width > view.bounds.height ? view.bounds.height : view.bounds.width
        
        var width: CGFloat {
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
        var height: CGFloat {
            (width * 1.53) + (showNames ? 20 : 0)
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func setUpNavigationButtons() {
        
        navigationItem.setRightBarButtonItems([addComicsButton , editBarButton], animated: true)
        navigationItem.setLeftBarButtonItems([infoButton], animated: true)
        
        let barButtonIsEnabled = indexSelectionManager.publisher.tryMap{!$0.isEmpty}.replaceError(with: false)
        
        
        barButtonIsEnabled.weakAssign(to: \.isEnabled, on: groupBarButton).store(in: &cancelabels)
        barButtonIsEnabled.weakAssign(to: \.isEnabled, on: deleteBarButton).store(in: &cancelabels)
        
    }
    
    
    //MARK: actions
    @IBAction func addComicsButtonTapped(_ sender: Any) {
        presentDocumentPicker()
        
        
    }
    
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        //Definitions
        struct DeletingComics: LocalizedError {
            var errorDescription = "There is a problem with removing some of your comics!"
        }
        
        func deleteComics() throws {
            var comicNamesWithErrors = [String]()
            for name in comicsNames {
                do{
                    try dataService.deleteComicFromCoreData(withName: name)
                    try appfileManager.deleteFileInTheAppDiractory(withName: name)
                } catch { comicNamesWithErrors.append(name) }
            }
            if !comicNamesWithErrors.isEmpty { throw DeletingComics() }
            
        }
        //if we don't sorted high to low then we have a crash
        lazy var comicsNames: [String] = {
            let lowToHighIndexes = indexSelectionManager.indexes.sorted()
            let highToLowIndexes = lowToHighIndexes.reversed()
            
            return highToLowIndexes
                .map { fetchResultController.object(at: $0) }
                .map {$0.name}
                .compactMap { $0 }
        }()
        
        //Execution
        let names = comicsNames
            .filter { !$0.isEmpty }
            .reduce("", { partialResult, string in
                partialResult + string + ", "
            })
        
        let alert = UIAlertController(
            title: "Are you sure you want to delete these comics?",
            message: "\(names)",
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive) { [weak self] _ in
                do {
                    try deleteComics()
                    self?.indexSelectionManager.removeAll()
                    alert.dismiss(animated: true)
                } catch let e {
                    alert.dismiss(animated: true) { [weak self] in
                        self?.showAlert(with: (e as! DeletingComics).errorDescription, description: "")
                    }
                }
            }
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
        
        
//        for indexPath in highToLowIndexes{
//            let comic = fetchResultController.object(at: indexPath)
//            if let comicName = comic.name,
//                comicName != "" {
//                do{
//                    try dataService.deleteComicFromCoreData(withName: comicName)
//                    try appfileManager.deleteFileInTheAppDiractory(withName: comicName)
//
//                }catch {
//                    showAlert(with: "Oh!", description: "There is a problem with removing your comics")
//                }
//            }
//        }
        
        
    }

    @IBAction func groupBarButtonTapped(_ sender: Any) {
        let newGroupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupVC
        newGroupVC.comicsAboutToGroup = indexSelectionManager.indexes
            .map {fetchResultController.object(at: $0)}
        
        newGroupVC.dataService = dataService
        
        newGroupVC.newComicGroupAboutToAdd = { [weak self] groupName , comics in
            do {
                try self?.dataService.createANewComicGroup(name: groupName, comics: comics)
                self?.indexSelectionManager.removeAll()
            } catch {
                self?.showAlert(with: "Oh!", description: "An issue happend while creating your comic group. Please try again.")
            }
        }
        
        newGroupVC.comicsGroupAboutToMove = { [weak self] group, comics in
            do {
                try self?.dataService.changeGroupOf(comics: comics, to: group)
                self?.indexSelectionManager.removeAll()
            } catch {
                self?.showAlert(with: "Oh!", description: "An issue happend while moving your comics. Please try again.")
            }
        }
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
    
    
    
    
    //MARK: Top bar functions
    
    func updateNavBarWhenEditingChanged() {
        if editingMode {
            bottomToolbar.isHidden = false
            bottomToolbar.alpha = 0
            
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 1
            } completion: { (_) in
                
            }
            bottomToolbar.isHidden = false
            addComicsButton.isEnabled = false
            editBarButton.title = "Done"
            editBarButton.style = .done
        }else{
            
            UIView.animate(withDuration: 0.2) {
                self.bottomToolbar.alpha = 0
            } completion: { (_) in
                self.bottomToolbar.isHidden = true
            }
            addComicsButton.isEnabled = true
            editBarButton.title = "Edit"
            editBarButton.style = .plain
            
        }
    }
    
    
    //MARK: File functions
    
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
