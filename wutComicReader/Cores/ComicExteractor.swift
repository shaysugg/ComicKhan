//
//  exteractor.swift
//  
//
//  Created by Shayan on 7/9/19.
//

import Foundation
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



protocol ProgressDelegate {
    func newFileAboutToCopy(withName name: String)
    func newFileAboutToExtract(withName name:String, andNumber number:Int, inTotalFilesCount: Int?)
    func percentChanged(to value: Double)
    func extractingProcessFinished()
}

extension ProgressDelegate {
    func extractingProcessFinished(){}
    func percentChanged(to value: Double){}
    func newFileAboutToExtract(withName name:String, andNumber number:Int, inTotalFilesCount: Int?){}
}

fileprivate var keyPathToObserve = "fractionCompleted"





class ComicExteractor: NSObject {
    
    var rarExtractingProgress: Progress?
    var delegate: ProgressDelegate?
    
    
    private func extractZIP(withFileURL fileURL : URL) throws{
        
        do{
            let extractionDirectory = try createExtractionDirectories(forFileWithURL: fileURL)
            
            try Zip.unzipFile(fileURL,
                              destination: extractionDirectory.originalImagesDirectoryURL,
                              overwrite: true,
                              password: nil,
                              progress: { percent in
                /* percent will devide to 2 becuse we only on the halfway of extracting we still
                 have thumbnail extracting process */
                self.delegate?.percentChanged(to: percent / 2)
            })
            
            resizeExtractedImages(ofURL: extractionDirectory.originalImagesDirectoryURL,
                                  toURL: extractionDirectory.thumbnailImagesDirectoryURL)
            
        }catch {
            throw ExtractorError.unzipingCBZFailed
        }
        
    }
    
    private func extractRAR(withFileURL fileURL : URL) throws{
        
        var archive : URKArchive?
        
        
        
        do{
            let extractionDirectory = try createExtractionDirectories(forFileWithURL: fileURL)
            
            archive = try URKArchive(path: fileURL.path)
            rarExtractingProgress = Progress(totalUnitCount: 1)
            archive?.progress = rarExtractingProgress
            rarExtractingProgress?.addObserver(self, forKeyPath: keyPathToObserve, options: .new, context: nil)
            
            try archive?.extractFiles(to: extractionDirectory.originalImagesDirectoryURL.path,
                                      overwrite: true)
            
            rarExtractingProgress?.removeObserver(self, forKeyPath: keyPathToObserve)
            
            resizeExtractedImages(ofURL: extractionDirectory.originalImagesDirectoryURL,
                                  toURL: extractionDirectory.thumbnailImagesDirectoryURL)
            
            
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
        
        //change this to use contents of diractory
        guard let fileURLS = try? FileManager.default.contentsOfDirectory(at: URL.userDiractory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        
        let comicURLs = filterFilesWithAcceptedFormat(infileURLs: fileURLS)
        let comicDiractoriesCount = try? FileManager.default.contentsOfDirectory(at: URL.comicDiractory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).count
        let allCounts = comicURLs.count - (comicDiractoriesCount ?? 0)
        var counter = 1
        
        for url in comicURLs {
            let comicName = url.fileName()
            let comicFormat = url.pathExtension
            
            
            if !DidComicAlreadyExistInComicDiractory(name: comicName) {
                
                delegate?.newFileAboutToExtract(withName: comicName,
                                                andNumber: counter,
                                                inTotalFilesCount: allCounts > 0 ? allCounts : nil)
                
                do {
                    if comicFormat == "cbz" {
                        try extractZIP(withFileURL: url)
                         counter += 1
                    }else if comicFormat == "cbr" {
                        try extractRAR(withFileURL: url)
                         counter += 1
                    }else if comicFormat == "pdf"{
                        //todo
                    }
                    
                  
                    
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
    
    private func filterFilesWithAcceptedFormat(infileURLs urls: [URL]?) -> [URL] {
        
        guard let unrwappedURLs = urls else { return [] }
        
        return unrwappedURLs.filter { (url) -> Bool in
            ["cbr" , "cbz" , "pdf"].contains(url.pathExtension.lowercased())
        }
        
    }
    
    private func DidComicAlreadyExistInComicDiractory(name: String) -> Bool {
        do
        {
            let appDirectoryComics = try FileManager.default.contentsOfDirectory(atPath: URL.comicDiractory.path)
            return appDirectoryComics.contains(name)
        }catch{
            return false
        }
    }
    
    private func createExtractionDirectories(forFileWithURL fileURL: URL) throws -> ExtractionDirectory {
        var extractionDirectory: ExtractionDirectory!
        extractionDirectory = ExtractionDirectory(baseURL: URL.comicDiractory.appendingPathComponent(fileURL.fileName()))
        
        try FileManager.default.createDirectory(at: extractionDirectory.baseURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try FileManager.default.createDirectory(at: extractionDirectory.originalImagesDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try FileManager.default.createDirectory(at: extractionDirectory.thumbnailImagesDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        
        return extractionDirectory
    }
    
    
    
    
}


struct ExtractionDirectory {
    let baseURL: URL
    var originalImagesDirectoryURL: URL {
        baseURL.appendingPathComponent(ExtractionDirectory.originalImagesDirectoryName)
    }
    var thumbnailImagesDirectoryURL: URL {
        baseURL.appendingPathComponent(ExtractionDirectory.thumbnailImagesDirectoryName)
    }
    
    static var originalImagesDirectoryName = "original"
    static var thumbnailImagesDirectoryName = "thumbnail"
}
