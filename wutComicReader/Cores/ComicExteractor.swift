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
    
    
    private func convertPDFToImages(pdfURL: URL) throws {
        let extractionDirectory = try createExtractionDirectories(forFileWithURL: pdfURL)
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
                extractionDirectory.originalImagesDirectoryURL
                .appendingPathComponent(make3DigitString(from: pageNumber))
                .appendingPathExtension("jpeg")
            
            guard let imageDestination = CGImageDestinationCreateWithURL(imageDestinationURL as CFURL, kUTTypeJPEG, 1, nil),
            let cgImage = img.cgImage
            else { return }
            
            CGImageDestinationAddImage(imageDestination, cgImage, nil)
            CGImageDestinationFinalize(imageDestination)
            
            delegate?.percentChanged(to: Double(pageNumber) / Double(document.numberOfPages) / 2)
        }
            
            resizeExtractedImages(ofURL: extractionDirectory.originalImagesDirectoryURL, toURL: extractionDirectory.thumbnailImagesDirectoryURL)
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
        var counter = 1
        
        for url in comicURLs {
            let comicName = url.fileName()
            let comicFormat = url.pathExtension
            
            
            if !DidComicAlreadyExistInComicDiractory(name: comicName) {
                
                delegate?.newFileAboutToExtract(withName: comicName,
                                                andNumber: counter,
                                                inTotalFilesCount: comicURLs.count)
                
                do {
                    if comicFormat == "cbz" {
                        try extractZIP(withFileURL: url)
                    }else if comicFormat == "cbr" {
                        try extractRAR(withFileURL: url)
                    }else if comicFormat == "pdf"{
                        try convertPDFToImages(pdfURL: url)
                    }
                    
                    counter += 1
                    
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
            validComicFormats.contains(url.pathExtension.lowercased())
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
    
    
    private func make3DigitString(from number: Int) -> String {
        if number < 10 { return "00\(number)" }
        else if number < 100 { return "0\(number)" }
        else { return "\(number)" }
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
