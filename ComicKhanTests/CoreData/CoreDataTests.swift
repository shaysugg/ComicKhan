//
//  CoreDataTests.swift
//  ComicKhanTests
//
//  Created by Sha Yan on 3/6/1401 AP.
//  Copyright © 1401 AP wutup. All rights reserved.
//

import XCTest
@testable import ComicKhan
import CoreData
class CoreDataTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    override func setUpWithError() throws {
        try super.setUpWithError()
        managedObjectContext = createMockManagedContext()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        managedObjectContext = nil
    }

    
    func testComicDescription() {
        let comic = Comic(context: managedObjectContext)
        comic.name = "Name"
        comic.groupName = "Froup"
        comic.imageNames = ["A", "B", "C"]
        
        print(comic.description)
    }
}
