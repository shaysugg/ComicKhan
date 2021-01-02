//
//  LibraryVCTests.swift
//  ComicKhanTests
//
//  Created by Sha Yan on 4/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import UIKit
import CoreData

@testable import ComicKhan

class LibraryVCTests: XCTestCase {

    var libraryVC: LibraryVC!
    var mockContext: NSManagedObjectContext!
    var newComicsGroup: ComicGroup!
    
    override func setUpWithError() throws {
        libraryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LibraryVC") as! LibraryVC
        libraryVC.loadView()
        
        mockContext = createMockManagedContext()!
        libraryVC.dataService = DataService(managedContext: mockContext)
        libraryVC.fetchResultController = try! libraryVC.dataService.configureFetchResultController()
        newComicsGroup = libraryVC.dataService.groupForNewComics
        
    }

    override func tearDownWithError() throws {
        libraryVC = nil
        mockContext = nil
        newComicsGroup = nil
    }
    
    func testDataService() {
        XCTAssertNotNil(libraryVC.dataService)
        XCTAssertNotNil(libraryVC.fetchResultController)
        XCTAssertEqual(libraryVC.dataService.managedContext, mockContext)
        XCTAssertEqual(libraryVC.fetchResultController.managedObjectContext, mockContext)
        print(libraryVC.fetchResultController.sections?.first?.name)
//        XCTAssertEqual(libraryVC.fetchResultController.sections?.first?.name, newComicsGroup.name)
    }

    func testCollectionViewInsertation() {

        let newComic1 = Comic(context: mockContext)
        newComic1.name = "Batman"
        newComic1.imageNames = ["01" , "02" , "03"]
        newComic1.thumbnailNames = ["01" , "02" , "03"]
        newComic1.lastVisitedPage = 0
        newComic1.id = UUID()
        newComic1.ofComicGroup = newComicsGroup
        
        let newComic2 = Comic(context: mockContext)
        newComic2.name = "Superman"
        newComic2.imageNames = ["01" , "02" , "03"]
        newComic2.thumbnailNames = ["01" , "02" , "03"]
        newComic2.lastVisitedPage = 0
        newComic2.id = UUID()
        newComic2.ofComicGroup = newComicsGroup

        try! mockContext.save()
        

        try! libraryVC.fetchResultController.performFetch()
        print(libraryVC.fetchResultController.fetchedObjects)
        XCTAssertEqual(libraryVC.fetchResultController.fetchedObjects?.count, 2)
        XCTAssertEqual(libraryVC.fetchResultController.sections?.count, 1)
        XCTAssertEqual(libraryVC.bookCollectionView.numberOfItems(inSection: 0), 2)
        libraryVC.bookCollectionView.reloadData()
//        let cell = libraryVC.bookCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))
//        XCTAssertNotNil(cell)
        

    }

}
