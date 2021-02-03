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
import CoreGraphics
import MobileCoreServices

enum ExtractorError : Error {
    case unzipingCBZFailed
    case unzipingCBRFailed
    case unzipingPDFFailed
    case fileAlreadyExisted
    case formatIsNotRight
}



protocol ProgressDelegate: class {
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
    weak var delegate: ProgressDelegate?
    private(set) var totalComicCount = 0
    private(set) var currentComicNumber = 1
    
    private var userDirectory = URL.userDiractory
    private var comicDirectory = URL.comicDiractory
    
    
    
    func extractUserComicsIntoComicDiractory() {
        
        totalComicCount = calculateTotalNumberOfComicsInComicDirectory()
        
        //check for directories of comics first
        try? FileManager.default.subpathsOfDirectory(atPath: userDirectory.path)
            .map { userDirectory.appendingPathComponent($0) }
            .filter { $0.pathExtension.isEmpty }
            .forEach({ (url) in
                extractComics(inDirectoryWithURL: url, comicGroupName: url.lastPathComponent)
            })
        
        
        //then the other comics without directories
        extractComics(inDirectoryWithURL: userDirectory)
        
        delegate?.extractingProcessFinished()
        currentComicNumber = 1
    }
    
    private func calculateTotalNumberOfComicsInComicDirectory() -> Int {
        do {
            let urls = try FileManager.default.subpathsOfDirectory(atPath: userDirectory.path)
                .map { userDirectory.appendingPathComponent($0) }
            
            return filterFilesWithAcceptedFormat(infileURLs: urls).count
        }catch {
            return 0
        }
    }
    
    private func extractComics(inDirectoryWithURL url: URL, comicGroupName: String? = nil) {
        
        guard let fileURLS = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        
        let comicURLs = filterFilesWithAcceptedFormat(infileURLs: fileURLS)
        
        for url in comicURLs {
            let comicName = url.fileName()
            let comicFormat = url.pathExtension.lowercased()
            
            
            if !DidComicAlreadyExistInComicDiractory(name: comicName) {
                
                delegate?.newFileAboutToExtract(withName: comicName,
                                                andNumber: currentComicNumber,
                                                inTotalFilesCount: totalComicCount)
                
                do {
                    //create extraction Directories
                    let extractionDirectory = ExtractionDirectory(directoryName: url.fileName(),
                                                                  baseURL: comicDirectory)
                    try? extractionDirectory.createDirectories()
                    
                    //extract based on format
                    if comicFormat == "cbz" {
                        try extractZIP(withFileURL: url, toURL: extractionDirectory)
                    }else if comicFormat == "cbr" {
                        try extractRAR(withFileURL: url, toURL: extractionDirectory)
                    }else if comicFormat == "pdf"{
                        try convertPDFToImages(pdfURL: url, destinationURL: extractionDirectory)
                    }
                    
                    //write comicGroupName as metada if needed
                    if let groupName = comicGroupName {
                        try? extractionDirectory.write(metaData: .init(groupName: groupName))
                    }
                    
                    currentComicNumber += 1
                    
                }catch let error{
                    print("\(comicName) extract failed : \(error.localizedDescription)")
                    if let _ = error as? ExtractorError {
                        
                    }
                }
            }
        }
    }
    
    
    private func extractZIP(withFileURL fileURL: URL, toURL destinationURL: ExtractionDirectory) throws{
        
        do{
            try Zip.unzipFile(fileURL,
                              destination: destinationURL.originalImagesDirectoryURL,
                              overwrite: true,
                              password: nil,
                              progress: { percent in
                /* percent will devide to 2 becuse we only on the halfway of extracting we still
                 have thumbnail extracting process */
                self.delegate?.percentChanged(to: percent / 2)
            })
            
            resizeExtractedImages(ofURL: destinationURL.originalImagesDirectoryURL,
                                  toURL: destinationURL.thumbnailImagesDirectoryURL)
            
        }catch {
            throw ExtractorError.unzipingCBZFailed
        }
    }
    
    
    private func extractRAR(withFileURL fileURL: URL, toURL destinationURL: ExtractionDirectory) throws{
        
        var archive : URKArchive?
        
        do{
            archive = try URKArchive(path: fileURL.path)
            rarExtractingProgress = Progress(totalUnitCount: 1)
            archive?.progress = rarExtractingProgress
            rarExtractingProgress?.addObserver(self, forKeyPath: keyPathToObserve, options: .new, context: nil)
            
            try archive?.extractFiles(to: destinationURL.originalImagesDirectoryURL.path,
                                      overwrite: true)
            
            rarExtractingProgress?.removeObserver(self, forKeyPath: keyPathToObserve)
            
            resizeExtractedImages(ofURL: destinationURL.originalImagesDirectoryURL,
                                  toURL: destinationURL.thumbnailImagesDirectoryURL)
            
            
        }catch {
            throw ExtractorError.unzipingCBRFailed
        }
    }
    
    
    private func convertPDFToImages(pdfURL: URL, destinationURL: ExtractionDirectory) throws {

        guard let document = CGPDFDocument(pdfURL as CFURL) else { return }
            
        let queue = DispatchQueue(label: "imagetodata", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil)
        
        queue.sync {
        
        for pageNumber in 1 ... document.numberOfPages {
            guard let page = document.page(at: pageNumber) else { return }
            
            let pageRect = page.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(page)
                
            }
//
            let imageDestinationURL =
                destinationURL.originalImagesDirectoryURL
                .appendingPathComponent(make3DigitString(from: pageNumber))
                .appendingPathExtension("jpeg")
            
            guard let imageDestination = CGImageDestinationCreateWithURL(imageDestinationURL as CFURL, kUTTypeJPEG, 1, nil),
            let cgImage = img.cgImage
            else { return }
            
            CGImageDestinationAddImage(imageDestination, cgImage, nil)
            CGImageDestinationFinalize(imageDestination)
            
            delegate?.percentChanged(to: Double(pageNumber) / Double(document.numberOfPages) / 2)
        }
            
            resizeExtractedImages(ofURL: destinationURL.originalImagesDirectoryURL, toURL: destinationURL.thumbnailImagesDirectoryURL)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == keyPathToObserve {
            if let percent = rarExtractingProgress?.fractionCompleted {
                delegate?.percentChanged(to: percent / 2)
            }
        }
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
            validComicFormats.contains(url.pathExtension.lowercased())
        }
        
    }
    
    private func DidComicAlreadyExistInComicDiractory(name: String) -> Bool {
        do
        {
            let appDirectoryComics = try FileManager.default.contentsOfDirectory(atPath: comicDirectory.path)
            return appDirectoryComics.contains(name)
        }catch{
            return false
        }
    }
    
    
    
    
    private func make3DigitString(from number: Int) -> String {
        if number < 10 { return "00\(number)" }
        else if number < 100 { return "0\(number)" }
        else { return "\(number)" }
    }
    
    ///use this init for testing purposes
    convenience init(testUserDirectory: URL, testComicDirectory: URL) {
        self.init()
        userDirectory = testUserDirectory
        comicDirectory = testComicDirectory
    }
    
}


