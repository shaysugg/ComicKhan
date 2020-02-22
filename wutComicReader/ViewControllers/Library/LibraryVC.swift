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
    var collectionViewCellSize: CGSize?
    
    let appfileManager = AppFileManager()
    let comicExtractor = ComicExteractor()
    
    var editingMode = false {
        didSet{
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
            refreshControll.isEnabled = !editingMode
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
        }
    }
    
//    var selectedSection: [Int] = []
    

    
    let refreshControll = UIRefreshControl()
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var groupBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var emptyGroupsView: UIView!
    
    var progressContainerView: UIView!
    var progressNameLabel: UILabel!
    var progressNumberLabel: UILabel!
    var progressView: RoundedProgressView!
    var progressContainerHeight: CGFloat {
        switch deviceType {
        case .iPad: return 130
        case .iPhone: return 130
        case .iPhoneX: return 160
        case .smalliPhone: return 140
        }
    }
    
    
    
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
        deviceIsLandscaped = UIDevice.current.orientation.isLandscape
    }
    
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        groupBarButton.title = ""
        deleteBarButton.title = ""
        
        makeCustomNavigationBar()
        setUpProgressBarDesign()
        bookCollectionView.backgroundColor = .appSystemBackground
        view.backgroundColor = .appSystemBackground
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
        refreshControll.tintColor = .clear
        refreshControll.subviews.first?.alpha = 0
        refreshControll.addTarget(self, action: #selector(unzipButtonTapped(_:)), for: .valueChanged)
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
    
    @IBAction func unzipButtonTapped(_ sender: Any) {
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

//MARK:- collectionView functions

extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comicGroups[section].comics?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! LibraryCell
        cell.selectionImageView.isHidden = !editingMode
        cell.readProgressView.isHidden = editingMode
        cell.book = comicGroups[indexPath.section].comics?[indexPath.row] as? Comic
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comicGroups.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath) as! LibraryReusableView
        header.headerLabel.text = comicGroups[indexPath.section].name
        header.isEditing = editingMode
        header.indexSet = indexPath.section
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
            readerVC.bookIndexInLibrary = indexPath
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

//extension LibraryVC: CellsEditableWithSectionDelegate {
//    func selectCellsOfSection(with indexSet: Int) {
//        guard let comicCount = comicGroups[indexSet].comics?.count, comicCount > 1 else { return }
//
//        if !selectedSection.contains(indexSet){
//            selectedSection.append(indexSet)
//            bookCollectionView.reloadSections(IndexSet(arrayLiteral: indexSet))
//        }
//
//        for indexRow in 0 ..< comicCount {
//            let cell = bookCollectionView.cellForItem(at: IndexPath(item: indexRow, section: indexSet))
//            cell?.isSelected = true
//        }
//
////        let reusableView = bookCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: indexSet)) as! LibraryReusableView
//
//
//    }
//
//    func diSelectCellsOfSection(with indexSet: Int) {
//        guard let comicCount = comicGroups[indexSet].comics?.count, comicCount > 1 else { return }
//
//        if selectedSection.contains(indexSet){
//            selectedSection.remove(at: indexSet)
//            bookCollectionView.reloadSections(IndexSet(arrayLiteral: indexSet))
//        }
//
//        for indexRow in 0...(comicCount - 1) {
//           let cell = bookCollectionView.cellForItem(at: IndexPath(item: indexRow, section: indexSet))
//            cell?.isSelected = false
//        }
//
////        let reusableView = bookCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: indexSet)) as! LibraryReusableView
////
//
//    }
//
//
//
    
//}
