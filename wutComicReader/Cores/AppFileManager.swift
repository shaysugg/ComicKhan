//
//  AppFileManager.swift
//  wutComicReader
//
//  Created by Sha Yan on 12/1/19.
//  Copyright © 2019 wutup. All rights reserved.
//

import Foundation
import UIKit
import CoreData


enum fileManagerError : Error {
    case deleteFailed
    case fetchFailed
}



class AppFileManager {
    
    //MARK:- Variables
    
    var comicDirectory : URL!
    var userDiractory : URL!
    private var fileManager = FileManager.default
    internal var managedContext : NSManagedObjectContext?
    var comicDiractoryName = "ComicFiles"
    
    //MARK:- Functions
    
    init() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate?.persistentContainer.viewContext
        
        userDiractory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentDir = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        comicDirectory = documentDir.appendingPathComponent(comicDiractoryName)
    }
    
    
    func deleteFileInTheUserDiractory(withName fileName : String) throws{
        if fileManager.subpaths(atPath: userDiractory.path)!.contains(fileName + ".cbz") {
            try fileManager.removeItem(at: userDiractory.appendingPathComponent(fileName + ".cbz"))
        }else if fileManager.subpaths(atPath: userDiractory.path)!.contains(fileName + ".cbr") {
            try fileManager.removeItem(at: userDiractory.appendingPathComponent(fileName + ".cbr"))
        }
    }
    
    func deleteFileInTheAppDiractory(withName fileName : String) throws{
        try fileManager.removeItem(at: comicDirectory.appendingPathComponent(fileName))
    }
    
    //write extracted comics in the comic diractory on core data
    //skip comics that already been added to core data
    
    func writeNewComicsOnCoreData(){
        
        guard let context = managedContext else { return }
        
        do{
            let comicDiractories = try fileManager.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for diractory in comicDiractories {
                guard let diractorySubPath = fileManager.subpaths(atPath: diractory.path) else {return}
                
                let comicName = makeComicNameFromPath(path: diractory.path)
                
                if !comicAlreadyExistedInCoreData(withName: comicName) {
                    
                    let comicImages = imagesPathsInSubPaths(subpaths: diractorySubPath)
                    
                    if !comicImages.isEmpty{
                        
                        let newComic = Comic(context: context)
                        newComic.name = comicName
                        newComic.imageNames = comicImages
                        newComic.id = UUID()
                        
                    }
                    do{
                        try context.save()
                    }catch let error {
                        print("erro happend while writing on core data: " + error.localizedDescription)
                        #warning("error handeling")
//                        throw error
                    }
                }
            }
            
        }catch let error{
            print("can't going through subpath of comicDir: " + error.localizedDescription )
        }
    }
    
    //check if every diractory in comic diractory do exsist in user diractory
    //if they don't (that means user deleted them manually)
    //then remove them from comic diractory too
       
    func syncRemovedComicsInUserDiracory() {
        
        guard let filePaths = fileManager.subpaths(atPath: userDiractory.path) else { return }
        //removing format with drop 4 characters in path
        let userDiractoryfilePaths = filePaths.map({$0.dropLast(4)})
        
        let comicDiractoriesPaths = try? fileManager.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).map({$0.path})
        
        
        for path in comicDiractoriesPaths ?? [] {
            let comicName = makeComicNameFromPath(path: path)
            if !userDiractoryfilePaths.contains(comicName.dropLast(0)){
                deleteComicFromCoreData(withName: comicName)
                try? deleteFileInTheAppDiractory(withName: comicName)
            }
        }
    }
    
    func didNewFileAddedToUserDiractory() -> Bool{
        let userFilePaths = FileManager.default.subpaths(atPath: userDiractory.path)
        let userComicPaths = filterFilesWithAcceptedFormat(infilePaths: userFilePaths)
        
        do {
            let documentComics = try fileManager.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return userComicPaths.count > documentComics.count
        }catch{
            return false
        }
        
    }
    
    //MARK:- private Functions
    
    private func filterFilesWithAcceptedFormat(infilePaths paths: [String]?) -> [String] {
        
        let acceptedFiles = paths?.filter { (path) -> Bool in
            guard let dotIndex = path.lastIndex(of: ".") else { return false }
            let endIndex = path.endIndex
            let range = dotIndex..<endIndex
            let formatName = path.substring(with:range)
            let acceptedFormats = [".cbr" , ".cbz" , ".pdf"]
            return acceptedFormats.contains(formatName)
        }
        
        return acceptedFiles ?? []
        
    }
    
        
    private func comicAlreadyExistedInCoreData(withName comicname: String) -> Bool{
        
            guard let context = managedContext else { return true }
            
            let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
            fetchRequest.predicate = NSPredicate(format: "name == %@", comicname)
            
            do{
                let sameComicsName = try context.fetch(fetchRequest)
                return !sameComicsName.isEmpty
            }catch let error{
                
                print("error hapened when fetching from core data: " + error.localizedDescription)
                //            throw error
                #warning("error handeling of this part man!")
                return false
            }
        }
    
    
    private func imagesPathsInSubPaths(subpaths: [String]) -> [String] {
        
        var comicImagesPaths : [String] = []
        
        let validFilePaths = subpaths.filter { (fileName) -> Bool in
            return fileName.contains(".jpg") || fileName.contains(".png")
            }.dropLast().sorted { $0 < $1 }
        
        for filePath in validFilePaths{
            comicImagesPaths.append(filePath)
        }
        return comicImagesPaths
    }
    
    
    private func makeComicNameFromPath(path: String) -> String {
        let startIndex = path.startIndex
        let slashIndex = path.lastIndex(of: "/")
        
        var subPath = path
        let range = startIndex ... slashIndex!
        subPath.removeSubrange(range)
        return subPath
    }
    
    func deleteComicFromCoreData(withName name: String){
        
        guard let context = managedContext else { return }
        
        let deletereq = NSFetchRequest<Comic>(entityName: "Comic")
        let predict = NSPredicate.init(format: "name == %@", name)
        deletereq.predicate = predict
        
        guard let comics = try? context.fetch(deletereq) else { return }
        for comic in comics {
            context.delete(comic)
        }
        try? context.save()
    }
    
    func makeAppDirectory() throws{
        try fileManager.createDirectory(at: comicDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func DidComicAlreadyExistInComicDiractory(name: String) -> Bool {
        do
        {
            let appDirectoryComics = try fileManager.contentsOfDirectory(atPath: comicDirectory.path)
            return appDirectoryComics.contains(name)
        }catch{
            return false
        }
    }
    
    
}
