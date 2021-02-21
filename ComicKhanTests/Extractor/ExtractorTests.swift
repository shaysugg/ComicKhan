//
//  coreTests.swift
//  coreTests
//
//  Created by Sha Yan on 1/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import UIKit
import Zip
import UnrarKit

@testable import ComicKhan

class ExtractorTests: XCTestCase {
    
    var extractor : ComicExteractor!
    var tempComicDirectory: URL!
    var tempUserDirectory: URL!
    let fileManager = FileManager()
    var testBundle: Bundle!
    
    enum Format {
        case cbz , cbr
        var string: String {
            switch self {
            case .cbr: return "cbr"
            case .cbz: return "cbz"
            }
        }
    }
    
    struct ComicInfo {
        let name: String
        let pageCount : Int
        let format: Format
        var pathComponent: String { name + "." + format.string }
    }
    
    struct ComicDirectory {
        let name: String
        let comicsInfo: [ComicInfo]
    }
    
    
    
    //MARK:- inital functions

    override func setUp() {
        super.setUp()
        creatTempDiractories()
        extractor = ComicExteractor(testUserDirectory: tempUserDirectory, testComicDirectory: tempComicDirectory)
        testBundle = Bundle(for: type(of: self))
        
    }
    
    func creatTempDiractories(){
        let tempFromURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "from")
        let tempToURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "to")
            try! fileManager.createDirectory(at: tempFromURL, withIntermediateDirectories: true, attributes: nil)
            try! fileManager.createDirectory(at: tempToURL, withIntermediateDirectories: true, attributes: nil)
        tempUserDirectory = tempFromURL
        tempComicDirectory = tempToURL
    }

    override func tearDown() {
        try! fileManager.removeItem(at: tempUserDirectory)
        try! fileManager.removeItem(at: tempComicDirectory)
        extractor = nil
        tempComicDirectory = nil
        tempUserDirectory = nil
        super.tearDown()
    }
    

    
    
    //MARK:- test functions
    
    //test initial values
    
    func testCashDirectoriesDoExist() {
        XCTAssertEqual(tempUserDirectory.path, NSTemporaryDirectory() + "from")
        XCTAssertEqual(tempComicDirectory.path, NSTemporaryDirectory() + "to")
    }
    
    //extractor search through "sutAppfileManager.userDiractory" and extact all the comic files to "sutAppfileManager.comicDiractory" and check files extracted completely or not.
    func testUserComicsDoExtractInComicDiractory() throws{
        //given
        
        let comicInfo = ComicInfo(name: "1-fish",
                                  pageCount: 1,
                                  format: .cbz)
        
        
        let comicFilePath = testBundle.path(forResource: comicInfo.name, ofType: comicInfo.format.string)
        
        XCTAssertNotNil(comicFilePath)
        
        //copy test comic to temp folder
        try! fileManager.copyItem(at: URL(fileURLWithPath: comicFilePath!) , to: tempUserDirectory.appendingPathComponent(comicInfo.name + "." + comicInfo.format.string))
        
        let coppiedComicPath = tempUserDirectory.appendingPathComponent(comicInfo.name + "." + comicInfo.format.string).path
        let didComicCoppied = fileManager.fileExists(atPath: coppiedComicPath)
        
        XCTAssertTrue(didComicCoppied)
        
        //when
        
        extractor.extractUserComicsIntoComicDiractory()

        let extractionURL = tempComicDirectory.appendingPathComponent(comicInfo.name)
        let extractedExist = fileManager.fileExists(atPath: extractionURL.path)
        
        //then
        
        
        XCTAssertTrue(extractedExist, "File extracted?")
        
        let extractionDirectory = ExtractionDirectory(directoryName: extractionURL.fileName(),
                                                      baseURL: tempComicDirectory)
        let extractedFilesCount =
            try fileManager.contentsOfDirectory(
                at: extractionDirectory.originalImagesDirectoryURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)
            .filter { validImageFormats.contains($0.pathExtension.lowercased()) }
            .count
        
        
        XCTAssertEqual(extractedFilesCount, comicInfo.pageCount)
        
    }
    
    func testNumberOfComicsAboutToExtract() {
        let infos: [ComicInfo] = [
            .init(name: "1-fish", pageCount: 1, format: .cbz),
            .init(name: "2-dogs", pageCount: 2, format: .cbz),
            .init(name: "3-fish", pageCount: 3, format: .cbz),
            .init(name: "4-dogs", pageCount: 4, format: .cbz)
        ]
        
        let comicDirectories: [ComicDirectory] = [
            .init(name: "1", comicsInfo: [infos[0], infos[1]]),
            .init(name: "2", comicsInfo: [infos[2], infos[3]])
        ]

        
        
        for directory in comicDirectories {
            //create directory first
            let dirURL = tempUserDirectory.appendingPathComponent(directory.name)
            try! fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
            
            //move its comics
            for info in directory.comicsInfo {
                let url = testBundle.url(forResource: info.name, withExtension: info.format.string)!
                try! fileManager.copyItem(at: url, to: dirURL.appendingPathComponent(info.pathComponent))
            }
        }
        
        extractor.extractUserComicsIntoComicDiractory()
        
        //check if total numbers match
        XCTAssertEqual(extractor.totalComicCount, 4)
    }

}
