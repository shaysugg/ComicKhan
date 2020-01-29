//
//  coreTests.swift
//  coreTests
//
//  Created by Sha Yan on 1/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import UIKit
import ZIPFoundation
import UnrarKit

@testable import wutComicReader

class ExtractorTests: XCTestCase {
    
    var sut : ComicExteractor!
    var sutAppFileManager : AppFileManager!
    let fileManager = FileManager.default
    
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
    }
    
    
    
    //MARK:- inital functions

    override func setUp() {
        super.setUp()
        
        sut = ComicExteractor.init()
        sutAppFileManager = sut.appFileManager
        
        creatTempDiractories()
        
        
    }
    
    func creatTempDiractories(){
        let tempFromURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "from")
        let tempToURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "to")
            try! fileManager.createDirectory(at: tempFromURL, withIntermediateDirectories: true, attributes: nil)
            try! fileManager.createDirectory(at: tempToURL, withIntermediateDirectories: true, attributes: nil)
        sutAppFileManager.userDiractory = tempFromURL
        sutAppFileManager.comicDirectory = tempToURL
    }

    override func tearDown() {
        try! fileManager.removeItem(at: sutAppFileManager.userDiractory)
        try! fileManager.removeItem(at: sutAppFileManager.comicDirectory)
        sut = nil
        super.tearDown()
    }
    

    
    
    //MARK:- test functions
    
    //test initial values
    
    func testCashDirectoriesDoExist() {
        XCTAssertEqual(sutAppFileManager.userDiractory.path, NSTemporaryDirectory() + "from")
        XCTAssertEqual(sutAppFileManager.comicDirectory.path, NSTemporaryDirectory() + "to")
    }
    
    //extractor search through "sutAppfileManager.userDiractory" and extact all the comic files to "sutAppfileManager.comicDiractory" and check files extracted completely or not.
    
    func testUserComicsDoExtractInComicDiractory(){
        //given
        
        let comicInfo = ComicInfo(name: "Skulldigger and Skeleton Boy 002 (2020) (digital) (Son of Ultron-Empire)",
                                  pageCount: 26,
                                  format: .cbr)
        
        let testBundle = Bundle(for: type(of: self))
        let comicFilePath = testBundle.path(forResource: comicInfo.name, ofType: comicInfo.format.string)
        
        //copy test comic to temp folder
        try! fileManager.copyItem(at: URL(fileURLWithPath: comicFilePath!) , to: sutAppFileManager.userDiractory.appendingPathComponent(comicInfo.name + "." + comicInfo.format.string))
        
        let coppiedComicPath = sutAppFileManager.userDiractory.appendingPathComponent(comicInfo.name + "." + comicInfo.format.string).path
        let didComicCoppied = fileManager.fileExists(atPath: coppiedComicPath)
        
        //when
        
        measure {
            sut.extractUserComicsIntoComicDiractory()
        }
        let extractedPath = sutAppFileManager.comicDirectory.appendingPathComponent(comicInfo.name).path
        let extractedExist = fileManager.fileExists(atPath: extractedPath)
        
        //then
        
        XCTAssertNotNil(comicFilePath)
        
        XCTAssertTrue(didComicCoppied)
        
        XCTAssertTrue(extractedExist, "file extracted succsesfully")
        
        let extractedFilesCount = fileManager.subpaths(atPath: extractedPath)!.count
        XCTAssertEqual(extractedFilesCount, comicInfo.pageCount)
        
    }
    

    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
