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

protocol AppFileManagerErrorDelegate: class {
    func errorsAccured(errors: [AppFileManager.AppFileManagerError])
}

extension AppFileManager {
    struct AppFileManagerError {
        let type: AppFileManagerErrorType
        let comicName: String?
    }
    enum AppFileManagerErrorType {
        case cantWriteOnCoreData
        case cantReadComicDirectory
        case emptyFile
    }
}


class AppFileManager {
    
    //MARK:- Variables
    
    let comicDirectory: URL
    let userDirectory: URL
    
    private var fileManager = FileManager.default
    var dataService: DataService!
    weak var progressDelegate: ProgressDelegate?
    
    var errors = [AppFileManagerError]()
    weak var errorDelegate: AppFileManagerErrorDelegate?
    
    //MARK:- Functions
    
    init(dataService: DataService, userDirectory: URL, comicDirectory: URL) {
        self.dataService = dataService
        self.comicDirectory = comicDirectory
        self.userDirectory = userDirectory
        
    }
    
    func deleteAllUserDirectoryContent() throws {
        try fileManager.contentsOfDirectory(at: userDirectory, includingPropertiesForKeys: nil)
            .forEach({ (url) in
                try fileManager.removeItem(at: url)
            })
    }
    
    func deleteFileInTheUserDiractory(withName fileName : String) throws{
        if fileManager.subpaths(atPath: userDirectory.path)!.contains(fileName + ".cbz") {
            try fileManager.removeItem(at: userDirectory.appendingPathComponent(fileName + ".cbz"))
        }else if fileManager.subpaths(atPath: userDirectory.path)!.contains(fileName + ".cbr") {
            try fileManager.removeItem(at: userDirectory.appendingPathComponent(fileName + ".cbr"))
        }
    }
    
    func deleteFileInTheAppDiractory(withName fileName : String) throws{
        try fileManager.removeItem(at: comicDirectory.appendingPathComponent(fileName))
    }
    
    func filesInUserDiractory() -> [URL]? {
        try? fileManager.contentsOfDirectory(at: userDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }
    
    ///write extracted comics in the comic diractory on core data
    ///skip comics that already been added to core data
    
    func writeNewComicsOnCoreData(){
        
        
        guard let comicDiractories = try? fileManager.contentsOfDirectory(at: comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            errors.append(AppFileManagerError(type: .cantReadComicDirectory, comicName: nil))
            return
        }
        
        
        for diractory in comicDiractories {
            
            let comicName = diractory.lastPathComponent
            
            let extractionDirectory = ExtractionDirectory(directoryName: comicName)
            
            if !dataService.comicAlreadyExistedInCoreData(withName: comicName) {
                
                // comicImageNames = [("original" or "thumbnail") + image name]
                guard
                    let comicImageNames = try? sortedOriginalImagesSubpaths(in: extractionDirectory),
                    let thumbnailImages = try? sortedThumbnailImagesSubpaths(in: extractionDirectory),
                    !comicImageNames.isEmpty,
                    !thumbnailImages.isEmpty
                else {
                    try? deleteFileInTheUserDiractory(withName: comicName)
                    try? deleteFileInTheAppDiractory(withName: comicName)
                    errors.append(AppFileManagerError(type: .emptyFile, comicName: comicName))
                    continue
                }
                
                do{
                    let groupName = try? extractionDirectory.readMetaData().groupName
                    try dataService.addNewComic(name: comicName,
                                                imageNames: comicImageNames,
                                                thumbnailNames: thumbnailImages,
                                                toComicGroupWithName: groupName)
                }catch {
                    errors.append(AppFileManagerError(type: .cantWriteOnCoreData, comicName: comicName))
                    continue
                }
            }
        }
        
        if !errors.isEmpty { errorDelegate?.errorsAccured(errors: errors) }
        errors.removeAll()
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


