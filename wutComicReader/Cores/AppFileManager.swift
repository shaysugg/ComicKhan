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


fileprivate var comicDiractoryName = "ComicFiles"

extension URL {
    static var comicDiractory: URL {
       return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(comicDiractoryName)
    }
    static var userDiractory: URL {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}


class AppFileManager {
    
    //MARK:- Variables
    
    var comicDirectory = URL.comicDiractory
    var userDiractory = URL.userDiractory
    private var fileManager = FileManager.default
    internal var managedContext : NSManagedObjectContext?
    var dataService: DataService!
    var comicDiractoryName = "ComicFiles"
    var progressDelegate: ProgressDelegate?
    
    //MARK:- Functions
    
    init(dataService: DataService) {
        managedContext = dataService.managedContext
        self.dataService = dataService
        
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
    
    func filesInUserDiractory() -> [URL]? {
        try? fileManager.contentsOfDirectory(at: userDiractory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }
    
    ///write extracted comics in the comic diractory on core data
    ///skip comics that already been added to core data
    
    func writeNewComicsOnCoreData() throws{
        
        guard let _ = managedContext else { return }
        
        do{
            let comicDiractories = try fileManager.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            
            for diractory in comicDiractories {
                let originalImagesDir = diractory.appendingPathComponent(ExtractionFolder.original.name)
                let thumbnailImagesDir = diractory.appendingPathComponent(ExtractionFolder.thumbnail.name)
                
                guard
                    let originalImagesDirSubPaths = fileManager.subpaths(atPath: originalImagesDir.path),
                    let thumbnailsDirSubPaths = fileManager.subpaths(atPath: thumbnailImagesDir.path)
                    else {return}
                
                let comicName = makeComicNameFromPath(path: diractory.path)
                
                if !dataService.comicAlreadyExistedInCoreData(withName: comicName) {
                    
                    let comicImages = imagesPathsInSubPaths(originalImagesDirSubPaths, inExtractionFolder: .original)
                    let thumbnailImages = imagesPathsInSubPaths(thumbnailsDirSubPaths, inExtractionFolder: .thumbnail)
                    
                    if !comicImages.isEmpty {
                        
                        do{
                            try dataService.addNewComic(name: comicName,
                                                        imageNames: comicImages,
                                                        thumbnailNames: thumbnailImages,
                                                        to: nil)
                        }catch let error {
                            try? deleteFileInTheUserDiractory(withName: comicName)
                            throw error
                        }
                    }else {
                        try? deleteFileInTheUserDiractory(withName: comicName)
                        try? deleteFileInTheAppDiractory(withName: comicName)
                    }
                }
            }
            
        }catch let error{
            print("can't going through subpath of comicDir: " + error.localizedDescription )
        }
    }
    
    
    
    func moveFilesToUserDiractory(urls: [URL]) throws {
        do {
            for url in urls {
                
                let comicName = makeComicNameFromPath(path: url.path)
                progressDelegate?.newFileAboutToCopy(withName: comicName)
                try fileManager.moveItem(at: url, to: URL.userDiractory.appendingPathComponent(comicName))
                
            }
        }catch let err {
            
            throw err
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
    
    
    private func imagesPathsInSubPaths(_ subpaths: [String], inExtractionFolder folder: ExtractionFolder) -> [String] {
        
        var comicImagesPaths : [String] = []
        
        let validFilePaths =
            subpaths.filter { (fileName) -> Bool in
                return fileName.contains(".jpg") || fileName.contains(".png")
            }
            .sorted { $0 < $1 }
            .map({ folder.name + "/" + $0 })
        
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


