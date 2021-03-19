//
//  ExtractionDirectoriesTests.swift
//  ComicKhanTests
//
//  Created by Sha Yan on 1/24/21.
//  Copyright © 2021 wutup. All rights reserved.
//

import XCTest
@testable import ComicKhan

class ExtractionDirectoriesTests: XCTestCase {

    var extractionDir: ExtractionDirectory!
    let extractionDirdName = "extraction-test"
    let fileManager = FileManager.default
    
    override func setUpWithError() throws {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        extractionDir = ExtractionDirectory(directoryName: extractionDirdName, baseURL: tempURL)
        try! extractionDir.createDirectories()
    }

    override func tearDownWithError() throws {
        try? fileManager.removeItem(at: extractionDir.baseURL)
        extractionDir = nil
    }

    func testWriteAndReadMetaData() throws {
        let groupName = "test-group"
        try! extractionDir.write(metaData: .init(groupName: groupName))
        let meteData = try! extractionDir.readMetaData()
        XCTAssertEqual(meteData.groupName, groupName)
        
    }

}
