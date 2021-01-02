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
    
    var comicDirectory = URL.comicDiractory
    var userDiractory = URL.userDiractory
    private var fileManager = FileManager.default
    internal var managedContext : NSManagedObjectContext?
    var dataService: DataService!
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
                
                let extractionDirectory = ExtractionDirectory(baseURL: diractory)
                
                let comicName = diractory.lastPathComponent
                
                if !dataService.comicAlreadyExistedInCoreData(withName: comicName) {
                    
                    // comicImageNames = [("original" or "thumbnail") + image name]
                    guard
                        let comicImageNames = try? sortedOriginalImagesSubpaths(in: extractionDirectory),
                        let thumbnailImages = try? sortedThumbnailImagesSubpaths(in: extractionDirectory)
                    else { return }
                    
                    if !comicImageNames.isEmpty {
                        
                        do{
                            try dataService.addNewComic(name: comicName,
                                                        imageNames: comicImageNames,
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
                
                let comicName = url.fileName()
                progressDelegate?.newFileAboutToCopy(withName: comicName)
                try fileManager.moveItem(at: url, to: URL.userDiractory.appendingPathComponent(url.lastPathComponent))
                
            }
        }catch let err {
            
            throw err
        }
    }
    
    //MARK:- private Functions
    
    // return an array of original/imageName
    private func imageSubPaths(InDirectoryWithURL url: URL) throws -> [String] {
        
        return try fileManager.subpathsOfDirectory(atPath: url.path)
            
            .filter {string -> Bool in
                for format in validImageFormats where string.contains("." + format) {
                    return true
                }
                return false
            }
        
    }
    
    private func sortedOriginalImagesSubpaths(in extractonDirectory: ExtractionDirectory) throws -> [String] {
        return try imageSubPaths(InDirectoryWithURL: extractonDirectory.originalImagesDirectoryURL)
            .map {ExtractionDirectory.originalImagesDirectoryName + "/" + $0}
            .sorted()
    }
    
    private func sortedThumbnailImagesSubpaths(in extractonDirectory: ExtractionDirectory) throws -> [String] {
        return try imageSubPaths(InDirectoryWithURL: extractonDirectory.thumbnailImagesDirectoryURL)
            .map {ExtractionDirectory.thumbnailImagesDirectoryName + "/" + $0}
            .sorted()
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


