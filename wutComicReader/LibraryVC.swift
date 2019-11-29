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

class LibraryVC: UIViewController {
    
    //MARK:- variables
    
    var appDirectory : URL?
    var userDiractory : URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    var bottomGradientImage : UIImageView?
    var comics : [[Comic]] = [[]]
    var sectionNames : [String] = ["New Comics"]
    var collectionViewCellSize: CGSize?
    
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
    
    //MARK:- actions
    
    @IBAction func unzipButtonTapped(_ sender: Any) {
        unzipAll()
        fetchComics()
        bookCollectionView.reloadData()
    }
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        
        deleteSelectedComics()
        
    }
    @IBAction func groupBarButtonTapped(_ sender: Any) {
        
        
        
        let alert = UIAlertController(title: "New Group Title", message: "enter the new group title", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.text = ""
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.makingAnAppGroup(with: alert.textFields![0].text ?? "")
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
        
        fetchComics()
        bookCollectionView.reloadData()
    }
    
    
    @IBAction func closeSectionButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK:- Design functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //line below is could be wrong!
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
            makeAppDirectory()
        }
        //        makeRandomComic()
        bookCollectionView.allowsMultipleSelection = true
        fetchComics()
        setUpDesigns()
        bookCollectionView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        print(NSHomeDirectory())
        
    }
    
    func makeRandomComic() {
        let comic1 = Comic(cover: UIImage(named: "001-p"), name: "first tank girl", pageNumbers: 1, pages: [UIImage(named: "001-p")!])
        let comic2 = Comic(cover: UIImage(named: "002-p"), name: "second tank girl", pageNumbers: 1, pages: [UIImage(named: "002-p")!])
        let comic3 = Comic(cover: UIImage(named: "003-p"), name: "third tank girl", pageNumbers: 1, pages: [UIImage(named: "003-p")!])
        let comic4 = Comic(cover: UIImage(named: "004-p"), name: "fourth tank girl", pageNumbers: 1, pages: [UIImage(named: "004-p")!])
        let comic5 = Comic(cover: UIImage(named: "005-p"), name: "fifth tank girl", pageNumbers: 1, pages: [UIImage(named: "005-p")!])
        let comic6 = Comic(cover: UIImage(named: "007-p"), name: "sixth tank girl", pageNumbers: 1, pages: [UIImage(named: "007-p")!])
        comics.append(contentsOf: [[comic1 , comic2 , comic3 , comic4] , [comic5 , comic6]])
        
        sectionNames.append(contentsOf: ["Tank Girl Series One" , "Tank Girl Series Two"])
        print(comics)
        bookCollectionView.reloadData()
    }
    
    func setUpDesigns(){
        
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        groupBarButton.title = ""
        deleteBarButton.title = ""
        
        makeCustomNavigationBar()
    }
    
    @objc func deviceDidRotated() {
        let deviceWidth = UIScreen.main.bounds.width
        print("device width is : \(UIScreen.main.bounds.width)")
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
    
    //MARK:- top bar functions
    
    func deleteSelectedComics() {
        
        selectedCell.sort()
        selectedCell.reverse()
        
        for index in selectedCell {
            comics[index.section].remove(at: index.row)
        }
        
        //removing empty section
        
        for comic in comics {
            if comic.isEmpty && comic != comics.first {
                if let index = comics.firstIndex(of: comic) {
                    comics.remove(at: index)
                    sectionNames.remove(at: index)
                }
            }
        }
        
        //        bookCollectionView.deleteItems(at: selectedCell)
        selectedCell.removeAll()
        bookCollectionView.reloadData()
    }
    
    
    func makingAnAppGroup(with name: String){
        
        if selectedCell.count < 2 { return }
        
        
        //creating a group in array
        
        var selectedComics : [Comic] = []
        
        selectedCell.sort()
        selectedCell.reverse()
        
        for indexpath in selectedCell {
            let cell = bookCollectionView.cellForItem(at: indexpath) as? BookCell
            if let book = cell?.book {
                comics[indexpath.section].remove(at: indexpath.row)
                selectedComics.append(book)
            }
        }
        comics.append(selectedComics)
        sectionNames.append(name)
        
        //removing empty sections that may generate after grouping
        
        for comic in comics {
            if comic.isEmpty {
                if let index = comics.firstIndex(of: comic) {
                    comics.remove(at: index)
                    sectionNames.remove(at: index)
                }
            }
        }
        
        bookCollectionView.reloadData()
        
        
    }
    
    func makeCustomNavigationBar(){
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    
    //MARK:- file functions
    
    
    func makeAppDirectory(){
        let documentDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        appDirectory = documentDir.appendingPathComponent("wutComic")
        
        do{
            try FileManager.default.createDirectory(at: appDirectory!, withIntermediateDirectories: true, attributes: nil)
        }catch {
            print("couldn't create the app directory")
        }
    }
    
    
    func printContent(subPath : String?) {
        
        let Url = appDirectory
        let subpathh = FileManager.default.subpaths(atPath: appDirectory!.path)
        print(subpathh ?? "")
        
        
        do{
            print(Url ?? "")
            let contents = try FileManager.default.contentsOfDirectory(atPath: Url!.path)
            print(contents)
        }catch {
            
        }
    }
    
    func deleteFile(at fileName : String){
        do {
            try FileManager.default.removeItem(at: userDiractory!.appendingPathComponent(fileName))
        }catch{
            print("couldnt delete file : \(fileName)")
            return
        }
    }
    
    func fetchComics(){
        #warning("we shouldnt delete all the comics and add all of them again!")
        comics[0].removeAll()
        
        var folders : [URL] = []
        
        do{
            folders = try FileManager.default.contentsOfDirectory(at: appDirectory!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for folder in folders {

                guard let files = FileManager.default.subpaths(atPath: folder.path) else {
                    print("the folder has no files")
                    return
                }
                
                let validFilePaths = files.filter { (fileName) -> Bool in
                    return fileName.contains(".jpg") || fileName.contains(".png")
                }.sorted { $0 < $1 }
                
                let comicName = makeComicNameFromPath(path: folder.path)
                var comicImages : [UIImage] = []
                //                var comicCover : UIImage?
                
                
                for file in validFilePaths{
                    
                    if let image = UIImage(contentsOfFile: folder.path + "/" + file) {
                        comicImages.append(image)
                    }
                }
                
                let fetchedComic = Comic(cover: comicImages.first, name: comicName, pageNumbers: comicImages.count, pages: comicImages)
                comics[0].append(fetchedComic)
            }
            
        }catch{
            print("cant fetched app comic files")
        }
        
        
        
    }
    
    func newFileHasBeenAdded() -> Bool {
        return false
    }
    
    func unzipAll() {
        let filePaths = FileManager.default.subpaths(atPath: userDiractory!.path)
        
        let comicPaths = filePaths?.filter({ (path) -> Bool in
            guard let dotIndex = path.lastIndex(of: ".") else { return false }
            let endIndex = path.endIndex
            let range = dotIndex..<endIndex
            let formatName = path.substring(with:range)
            let acceptedFormats = [".cbr" , ".cbz"]
            return acceptedFormats.contains(formatName)
        }) ?? []
        
        for path in comicPaths {
            var comicpath = path
            comicpath.removeLast(4)
            if !comicAlreadyExistedInAppDiractory(name: comicpath) {
                
                unzipingCBR(fileName: comicpath) { (error) in
                    if let _ = error {
                        return
                    }
                }
            }
        }
        
    }
    
    func comicAlreadyExistedInAppDiractory(name: String) -> Bool {
        do
        {
            let appDirectoryComics = try FileManager.default.contentsOfDirectory(atPath: appDirectory!.path)
            return appDirectoryComics.contains("Extracted-" + name)
        }catch{
            return false
        }
    }
    
    
    func makeComicNameFromPath(path: String) -> String {
        let startIndex = path.startIndex
        let slashIndex = path.lastIndex(of: "/")
        let nameIndex = path.index(slashIndex!, offsetBy: 10)
        
        var subPath = path
        let range = startIndex ... nameIndex
        subPath.removeSubrange(range)
        return subPath
    }
    
    
}

    //MARK:- collectionView functions

extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        cell.book = comics[indexPath.section][indexPath.row]
        cell.selectionImageView.isHidden = !editingMode
        cell.setUpDesign()
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comics.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath)
        let title = header.viewWithTag(101) as! UILabel
        let closeSectionButton = header.viewWithTag(102) as! UIButton
        title.text = sectionNames[indexPath.section]
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
            readerVC.comic = comics[indexPath.section][indexPath.row]
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
