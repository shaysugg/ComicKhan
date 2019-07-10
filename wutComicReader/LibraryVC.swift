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
    
    var appDirectory : URL?
    var comics : [Comic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //line below is could be wrong!
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
            makeAppDirectory()
        }
        fetchComics()
        bookCollectionView.reloadData()
        
    }
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBAction func unzipButtonTapped(_ sender: Any) {
//        unzipingCBR(fileName: "Dick Tracyy")
//        unzipingCBR(fileName: "Mr. Higgins Comes Home")
//        unzipingCBR(fileName: "Hellboy")
        unzipingCBR(fileName: "Batman")
//        unzipingCBR(fileName: "Wonder Woman")
        fetchComics()
        bookCollectionView.reloadData()
        
        
        
    }
    @IBAction func fetchButtonTapped(_ sender: Any) {
        
        fetchComics()
        bookCollectionView.reloadData()
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
                comics.append(comic)
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
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let bookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath)
        let bookImage = bookCell.viewWithTag(101) as! UIImageView
        let bookName = bookCell.viewWithTag(102) as! UILabel
        
        bookImage.image = comics[indexPath.row].cover
        bookName.text = comics[indexPath.row].name
        
        return bookCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3.5, height: collectionView.frame.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let readerVC = storyboard?.instantiateViewController(withIdentifier: "bookReader") as! BookReaderVC
//        let readerVC = BookReaderVC()
        readerVC.comic = comics[indexPath.row]
        present(readerVC , animated: true)
    }
    
    
}
