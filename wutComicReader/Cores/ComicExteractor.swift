//
//  exteractor.swift
//  
//
//  Created by Shayan on 7/9/19.
//

import Foundation
import ZIPFoundation
import UnrarKit
import UIKit
import Zip

enum ExtractorError : Error {
    case unzipingCBZFailed
    case unzipingCBRFailed
    case unzipingPDFFailed
    case fileAlreadyExisted
    case formatIsNotRight
}



class ComicExteractor {
    
    internal var appFileManager = AppFileManager()
    
    private func extractZIP(withFileName fileName : String) throws{
            
            let zipFileURL = appFileManager.userDiractory.appendingPathComponent(fileName + ".cbz")
            let extractedComicURL = appFileManager.comicDirectory.appendingPathComponent(fileName)
            
            do{
                try FileManager.default.createDirectory(at: extractedComicURL, withIntermediateDirectories: true, attributes: nil)
//                try FileManager.default.unzipItem(at: zipFileURL, to: extractedComicURL)
                try Zip.unzipFile(zipFileURL, destination: extractedComicURL, overwrite: true, password: nil)
            }catch {
                throw ExtractorError.unzipingCBZFailed
            }
        
    }
    
    
    
    
    private func extractRAR(withFileName fileName : String) throws{
        
        var archive : URKArchive?
        
        print(fileName)
        
        let zipFilePath = appFileManager.userDiractory.appendingPathComponent(fileName + ".cbr")
        let extractedComicsURL = appFileManager.comicDirectory.appendingPathComponent(fileName)
        
        do{
            try FileManager.default.createDirectory(at: extractedComicsURL, withIntermediateDirectories: true, attributes: nil)
            
            archive = try URKArchive(path: zipFilePath.path)
            try archive?.extractFiles(to: extractedComicsURL.path, overwrite: true, progress: nil)
            
        }catch {
            throw ExtractorError.unzipingCBRFailed
        }
        
    }
    
    
    func extractUserComicsIntoComicDiractory() {
            
            let filePaths = FileManager.default.subpaths(atPath: self.appFileManager.userDiractory.path)
            
            let comicPaths = filterFilesWithAcceptedFormat(infilePaths: filePaths)
            
            for path in comicPaths {
                let comicName = NameofFile(fromFilePath: path)
                let comicFormat = formatOfFile(fromFilePath: path)
                
                if !self.appFileManager.DidComicAlreadyExistInComicDiractory(name: comicName) {
                    
                    do {
                        if comicFormat == ".cbz" {
                            try extractZIP(withFileName: comicName)
                        }else if comicFormat == ".cbr" {
                            try extractRAR(withFileName: comicName)
                        }else{}
                        
                    }catch let error{
                        print("\(comicName) extract failed : \(error.localizedDescription)")
                        if let _ = error as? ExtractorError {
                            
                        }
                    }
                }
            }
        
    }
    
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
    
    private func NameofFile(fromFilePath path: String) -> String{
        guard let dotindex = path.lastIndex(of: ".") else { return ""}
        
        var startIndex: String.Index {
            if let slashIndex = path.lastIndex(of: "/"){
                return slashIndex
            }else{
                return path.startIndex
            }
        }
        
        let nameRange = startIndex..<dotindex
        let name = path.substring(with: nameRange)
        
        return String(name)
    }
    
    private func formatOfFile(fromFilePath path: String) -> String {
        let pathEndIndex = path.endIndex
        guard let dotindex = path.lastIndex(of: ".") else { return ""}
        
        let formatRange = dotindex..<pathEndIndex
        let formatName = path.substring(with: formatRange)
        return formatName
    }
    
    
}


