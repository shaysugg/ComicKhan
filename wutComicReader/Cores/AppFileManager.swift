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
    
    var comicDirectory : URL {
        let documentDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return documentDir.appendingPathComponent("wutComic")
    }
    
    var userDiractory : URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func deleteFileInTheUserDiractory(withName fileName : String) throws{
        try FileManager.default.removeItem(at: userDiractory.appendingPathComponent(fileName))
    }
    
    func deleteFileInTheAppDiractory(withName fileName : String) throws{
        try FileManager.default.removeItem(at: comicDirectory.appendingPathComponent("Extracted-" + fileName))
    }
    
    func writeNewComicsOnCoreData() throws{
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        do{
            let comicDiractories = try FileManager.default.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for diractory in comicDiractories {
                guard let diractorySubPath = FileManager.default.subpaths(atPath: diractory.path) else {return}
                
                let comicName = makeComicNameFromPath(path: diractory.path)
                
                if !comicAlreadyExistedInCoreData(withName: comicName) {
                    
                    let comicImages = imagesPathsInSubPaths(subpaths: diractorySubPath)
                    
                    if !comicImages.isEmpty{
                        
                        let newComic = Comic(context: managedContext)
                        newComic.name = comicName
                        newComic.imageNames = comicImages
                        newComic.id = UUID()
                        print(newComic.name)
                    }
                    
                    
                    
                    do{
                        try managedContext.save()
                    }catch let error {
                        print("erro happend while writing on core data: " + error.localizedDescription)
                        throw error
                    }
                }
            }
            
        }catch let error{
            print("can't going through subpath of comicDir: " + error.localizedDescription )
        }
    }
       
    func syncRemovedComicsInUserDiracory() {
        
        guard let filePaths = FileManager.default.subpaths(atPath: userDiractory.path) else { return }
        //removing format with drop 4 characters in path
        let userDiractoryfilePaths = filePaths.map({$0.dropLast(4)})
        print(userDiractoryfilePaths)
        
        let comicDiractoriesPaths = try? FileManager.default.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).map({$0.path})
        
        
        for path in comicDiractoriesPaths ?? [] {
            let comicName = makeComicNameFromPath(path: path)
            if !userDiractoryfilePaths.contains(comicName.dropLast(0)){
                deleteComicFromCoreData(withName: comicName)
                try? deleteFileInTheAppDiractory(withName: comicName)
            }
        }
    }
    
        
    private func comicAlreadyExistedInCoreData(withName comicname: String) -> Bool{
            
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
            let managedContext = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
            fetchRequest.predicate = NSPredicate(format: "name == %@", comicname)
            
            do{
                let sameComicsName = try managedContext.fetch(fetchRequest)
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
        let nameIndex = path.index(slashIndex!, offsetBy: 10)
        
        var subPath = path
        let range = startIndex ... nameIndex
        subPath.removeSubrange(range)
        return subPath
    }
    
    
    func printContent(subPath : String?) {
        
        let Url = comicDirectory
        let subpathh = FileManager.default.subpaths(atPath: comicDirectory.path)
        print(subpathh ?? "")
        
        
        do{
            print(Url)
            let contents = try FileManager.default.contentsOfDirectory(atPath: Url.path)
            print(contents)
        }catch {
            
        }
    }
    
    private func deleteComicFromCoreData(withName name: String){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let deletereq = NSFetchRequest<Comic>(entityName: "Comic")
        let predict = NSPredicate.init(format: "name == %@", name)
        deletereq.predicate = predict
        
        guard let comics = try? managedContext.fetch(deletereq) else { return }
        for comic in comics {
            managedContext.delete(comic)
        }
        try? managedContext.save()
    }
    
//    private func NameofFileInComicDiractory(fromFilePath path: String) -> String{
//        guard let dotindex = path.lastIndex(of: ".") else { return ""}
//
//        var startIndex: String.Index {
//            if let slashIndex = path.lastIndex(of: "/"){
//                return slashIndex
//            }else{
//                return path.startIndex
//            }
//        }
//
//        let nameRange = startIndex..<dotindex
//        var name = path.substring(with: nameRange)
////        name.removeFirst(10)
//
//        return String(name)
//    }
    
    func makeAppDirectory() throws{
        try FileManager.default.createDirectory(at: comicDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func DidComicAlreadyExistInComicDiractory(name: String) -> Bool {
        do
        {
            let appDirectoryComics = try FileManager.default.contentsOfDirectory(atPath: comicDirectory.path)
            return appDirectoryComics.contains("Extracted-" + name)
        }catch{
            return false
        }
    }
    
    
}
