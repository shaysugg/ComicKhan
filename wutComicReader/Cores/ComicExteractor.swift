//
//  exteractor.swift
//  
//
//  Created by Shayan on 7/9/19.
//

import Foundation
//import ZIPFoundation
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

enum ExtractionFolder {
    case original
    case thumbnail
    
    var name: String {
        switch self {
        case .original:
            return "original"
        case .thumbnail:
            return "thumbnail"
        }
    }
}


protocol ExtractingProgressDelegate {
    func newFileAboutToExtract(withName name:String, andNumber number:Int, inTotalFilesCount: Int?)
    func percentChanged(to value: Double)
    func extractingProcessFinished()
}

extension ExtractingProgressDelegate {
    func extractingProcessFinished(){}
    func percentChanged(to value: Double){}
    func newFileAboutToExtract(withName name:String, andNumber number:Int, inTotalFilesCount: Int?){}
}

fileprivate var keyPathToObserve = "fractionCompleted"

class ComicExteractor: NSObject {
    
    internal var appFileManager = AppFileManager()
    
    var rarExtractingProgress: Progress?
    var delegate: ExtractingProgressDelegate?
    
    
    private func extractZIP(withFileName fileName : String) throws{
        
        let zipFileURL = appFileManager.userDiractory.appendingPathComponent(fileName + ".cbz")
        let extractedComicURL = appFileManager.comicDirectory.appendingPathComponent(fileName)
        let extractedImagesURL = extractedComicURL.appendingPathComponent(ExtractionFolder.original.name)
        let extractedThumbnailsURL = extractedComicURL.appendingPathComponent(ExtractionFolder.thumbnail.name)
        
        do{
            try FileManager.default.createDirectory(at: extractedComicURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: extractedImagesURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: extractedThumbnailsURL, withIntermediateDirectories: true, attributes: nil)
            
            try Zip.unzipFile(zipFileURL, destination: extractedImagesURL, overwrite: true, password: nil, progress: { percent in
                /* percent will devide to 2 becuse we only on the halfway of extracting we still
                 have thumbnail extracting process */
                self.delegate?.percentChanged(to: percent / 2)
            })
            resizeExtractedImages(ofURL: extractedImagesURL, toURL: extractedThumbnailsURL)
            
        }catch {
            throw ExtractorError.unzipingCBZFailed
        }
        
    }
    
    private func extractRAR(withFileName fileName : String) throws{
        
        var archive : URKArchive?
        let zipFilePath = appFileManager.userDiractory.appendingPathComponent(fileName + ".cbr")
        let extractedComicsURL = appFileManager.comicDirectory.appendingPathComponent(fileName)
        let extractedImagesURL = extractedComicsURL.appendingPathComponent(ExtractionFolder.original.name)
        let extractedThumbnailsURL = extractedComicsURL.appendingPathComponent(ExtractionFolder.thumbnail.name)
        
        do{
            try FileManager.default.createDirectory(at: extractedComicsURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: extractedImagesURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: extractedThumbnailsURL, withIntermediateDirectories: true, attributes: nil)
            
            archive = try URKArchive(path: zipFilePath.path)
            rarExtractingProgress = Progress(totalUnitCount: 1)
            archive?.progress = rarExtractingProgress
            rarExtractingProgress?.addObserver(self, forKeyPath: keyPathToObserve, options: .new, context: nil)
            
            try archive?.extractFiles(to: extractedImagesURL.path, overwrite: true)
            
            rarExtractingProgress?.removeObserver(self, forKeyPath: keyPathToObserve)
            
            resizeExtractedImages(ofURL: extractedComicsURL, toURL: extractedThumbnailsURL)
            
            
        }catch {
            throw ExtractorError.unzipingCBRFailed
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == keyPathToObserve {
            if let percent = rarExtractingProgress?.fractionCompleted {
                delegate?.percentChanged(to: percent / 2)
            }
        }
    }
    
    func extractUserComicsIntoComicDiractory() {
        
        let filePaths = FileManager.default.subpaths(atPath: self.appFileManager.userDiractory.path)
        
        let comicPaths = filterFilesWithAcceptedFormat(infilePaths: filePaths)
        let comicDiractoriesCount = try? FileManager.default.contentsOfDirectory(at: appFileManager.comicDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).count
        let allCounts = comicPaths.count - (comicDiractoriesCount ?? 0)
        var counter = 1
        
        for path in comicPaths {
            let comicName = NameofFile(fromFilePath: path)
            let comicFormat = formatOfFile(fromFilePath: path)
            
            
            if !self.appFileManager.DidComicAlreadyExistInComicDiractory(name: comicName) {
                
                delegate?.newFileAboutToExtract(withName: comicName,
                                                andNumber: counter,
                                                inTotalFilesCount: allCounts > 0 ? allCounts : nil)
                
                do {
                    if comicFormat == ".cbz" {
                        try extractZIP(withFileName: comicName)
                         counter += 1
                    }else if comicFormat == ".cbr" {
                        try extractRAR(withFileName: comicName)
                         counter += 1
                    }else{}
                    
                  
                    
                }catch let error{
                    print("\(comicName) extract failed : \(error.localizedDescription)")
                    if let _ = error as? ExtractorError {
                        
                    }
                }
            }
           
            
        }
        delegate?.extractingProcessFinished()
        
    }
    
    private func resizeExtractedImages(ofURL comicURL: URL, toURL desURL: URL){
        
        if let imagePaths = FileManager.default.subpaths(atPath: comicURL.path) {
            
            let paths = imagePaths.map({ comicURL.path + "/" + $0 })
            let resizer = ImageResizer(for: paths , saveTo: desURL)
            resizer.startResizing(progress: { percent in
                delegate?.percentChanged(to: 0.5 + percent / 2)
            })
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


