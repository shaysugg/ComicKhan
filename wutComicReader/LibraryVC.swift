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
    var comics : [[Comic]] = []
    var bottomGradientImage : UIImageView?
    var sectionCount : Int = 1
    
    var editingMode = false {
        didSet{
//            navigationItem.largeTitleDisplayMode =  editingMode ? .never : .always
            if editingMode {
                groupBarButton.title = "Group"
                deleteBarButton.title = "Delete"
                editBarButton.title = "Done"
//                groupBarButton.isEnabled = true
//                deleteBarButton.isEnabled = true
            }else{
                groupBarButton.title = ""
                deleteBarButton.title = ""
                editBarButton.title = "edit"
                deleteBarButton.isEnabled = false
                groupBarButton.isEnabled = false
            }
        }
    }
    var selectedCell : [IndexPath] = [] {
        didSet{
            groupBarButton.isEnabled = !selectedCell.isEmpty
            deleteBarButton.isEnabled = !selectedCell.isEmpty
        }
    }
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var groupBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    //MARK:- actions
    
    @IBAction func unzipButtonTapped(_ sender: Any) {
//        unzipingCBR(fileName: "Dick Tracyy")
//        unzipingCBR(fileName: "Mr. Higgins Comes Home")
//        unzipingCBR(fileName: "Hellboy")
        unzipingCBR(fileName: "Batman")
//        unzipingCBR(fileName: "Wonder Woman")
        
        fetchComics()
        bookCollectionView.reloadData()
        
        
        
    }
    
    @IBAction func DeleteBarButtonTapped(_ sender: Any) {
        
        for index in selectedCell {
            comics[index.section].remove(at: index.row)
        }
        
        bookCollectionView.deleteItems(at: selectedCell)
        selectedCell.removeAll()
        bookCollectionView.reloadData()
        
    }
    @IBAction func groupBarButtonTapped(_ sender: Any) {
        
        if selectedCell.count < 2 { return }
        
        //creating a group in dataBase
        
        var selectedComics : [Comic] = []
        
        for indexpath in selectedCell {
            let cell = bookCollectionView.cellForItem(at: indexpath) as? BookCell
            if let book = cell?.book {
                comics[indexpath.section].remove(at: indexpath.row)
                selectedComics.append(book)
            }
        }
        comics.append(selectedComics)
        
        
        //removing empty sections that may generate after grouping
        
        for comic in comics {
            if comic.isEmpty {
                if let index = comics.firstIndex(of: comic) {
                    comics.remove(at: index)
                }
            }
        }
        
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
        bookCollectionView.reloadData()
    }
    
    @IBAction func fetchButtonTapped(_ sender: Any) {
        
        fetchComics()
        bookCollectionView.reloadData()
    }
    
    
    //MARK:- functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //line below is could be wrong!
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
            makeAppDirectory()
        }
        makeRandomComic()
        print(comics.count)
        bookCollectionView.allowsMultipleSelection = true
//        fetchComics()
        setUpDesigns()
        bookCollectionView.reloadData()
        
    }
    
    func makeRandomComic() {
        let comic1 = Comic(cover: UIImage(named: "001-ct"), name: "first tank girl", pageNumbers: 1, pages: [UIImage(named: "001-ct")!])
        let comic2 = Comic(cover: UIImage(named: "002-ct"), name: "second tank girl", pageNumbers: 1, pages: [UIImage(named: "002-ct")!])
        let comic3 = Comic(cover: UIImage(named: "003-ct"), name: "third tank girl", pageNumbers: 1, pages: [UIImage(named: "004-ct")!])
        let comic4 = Comic(cover: UIImage(named: "004-ct"), name: "fourth tank girl", pageNumbers: 1, pages: [UIImage(named: "004-ct")!])
        let comic5 = Comic(cover: UIImage(named: "005-ct"), name: "fifth tank girl", pageNumbers: 1, pages: [UIImage(named: "005-ct")!])
        let comic6 = Comic(cover: UIImage(named: "006-ct"), name: "sixth tank girl", pageNumbers: 1, pages: [UIImage(named: "006-ct")!])
        comics.append(contentsOf: [[comic1 , comic2 , comic3 , comic4] , [comic5 , comic6]])
        
        bookCollectionView.reloadData()
    }
    
    func setUpDesigns(){
        
        groupBarButton.isEnabled = false
        deleteBarButton.isEnabled = false
        groupBarButton.title = ""
        deleteBarButton.title = ""
        
        makeCustomNavigationBar()
        makeBottomViewGradiant()
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
    
    func makeCustomNavigationBar(){
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    
    func makeAppDirectory(){
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        appDirectory = documentDir.appendingPathComponent("wutComic")
        
        do{
            try FileManager.default.createDirectory(at: appDirectory!, withIntermediateDirectories: true, attributes: nil)
        }catch {
            print("couldn't create the app directory")
        }
    }
    
    
    func printContent(subPath : String?) {
        
        var Url = appDirectory
//        if let subpath = subPath {
//            Url = appDir!.appendingPathComponent(subpath)
//        }
        let subpathh = FileManager.default.subpaths(atPath: appDirectory!.path)
        print(subpathh)
        
        
        do{
            print(Url)
            let contents = try FileManager.default.contentsOfDirectory(atPath: Url!.path)
            print(contents)
        }catch {
            
        }
    }
    
    func fetchComics(){
        comics.removeAll()
        var folders : [URL] = []
        
        do{
            folders = try FileManager.default.contentsOfDirectory(at: appDirectory!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for folder in folders {
                print(folder.path)
                
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
                
                let comic = Comic(cover: comicImages.first, name: comicName, pageNumbers: comicImages.count, pages: comicImages)
                comics[0].append(comic)
            }
            
        }catch{
            print("cant fetched app comic files")
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

extension LibraryVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        cell.book = comics[indexPath.section][indexPath.row]
        cell.setUpDesign()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BookHeader", for: indexPath)
        let title = header.viewWithTag(101) as! UILabel
        let holder = header.viewWithTag(102)!
        holder.layer.cornerRadius = holder.frame.height * 0.5
        title.text = "Cat Woman Series"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if editingMode {
                if !selectedCell.contains(indexPath) {
                    selectedCell.append(indexPath)
//            cell.isSelected = !(cell?.isSelected ?? false)
            }
        }else{
            collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
            let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
            readerVC.comic = comics[indexPath.section][indexPath.row]
            present(readerVC , animated: true)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if editingMode{
            if selectedCell.contains(indexPath){
                guard let index = selectedCell.firstIndex(of: indexPath) else { return }
                selectedCell.remove(at: index)
            }
            print(indexPath)
        }
    }
    
    
}
