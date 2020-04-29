//
//  DataServiceTests.swift
//  ComicKhanTests
//
//  Created by Sha Yan on 4/25/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import CoreData

@testable import ComicKhan

class DataServiceTests: XCTestCase {
    
    var mockManagedContext: NSManagedObjectContext!
    var fakeComics = [Comic]()
    var fakeComicSections = [ComicGroup]()
    var dataService: DataService!
    
    override func setUpWithError() throws {
        mockManagedContext = createMockManagedContext()
        dataService = DataService(managedContext: mockManagedContext)
        try! dataService.createGroupForNewComics()
        createFakeData()
    }

    override func tearDownWithError() throws {
        mockManagedContext = nil
        dataService = nil
        fakeComics.removeAll()
        fakeComicSections.removeAll()
    }

    func testCreationOfMockManagedContext() {
        XCTAssertNotNil(mockManagedContext)
    }
    
    func testFetchRequest() {
        let fetchResultController = try! dataService.configureFetchResultController()
        
        XCTAssertEqual(fetchResultController.fetchedObjects?.count, fakeComics.count)
        
        XCTAssertEqual(fetchResultController.sections?.count, fakeComicSections.count)
        
        printComics()
    }
    
    func testFetchRequestSort() {
        let fetchResultController = try! dataService.configureFetchResultController()
        
        guard let firstSectionName = fetchResultController.sections?.first?.name else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(firstSectionName.contains("New Comics"))
    }
    
    func testDeleteAComic(){
        let fetchResultController = try! dataService.configureFetchResultController()
        
        
        try! dataService.deleteComicFromCoreData(withName: fakeComics[0].name ?? "")
        
        try! fetchResultController.performFetch()
        XCTAssertEqual(fetchResultController.fetchedObjects?.count, fakeComics.count - 1)
    }
    
    func testDeleteEmptyGroups(){
        let fetchResultController = try! dataService.configureFetchResultController()
        
        try! dataService.deleteComicFromCoreData(withName: fakeComics[0].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[1].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[2].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[3].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[4].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[5].name ?? "")
        try! dataService.deleteComicFromCoreData(withName: fakeComics[6].name ?? "")
        
        try! fetchResultController.performFetch()
        
        try! dataService.deleteEmptyGroups()
        
        try! fetchResultController.performFetch()
        
        print(fetchResultController.sections)
        
        let groups = try! dataService.fetchComicGroups()
        
        XCTAssertTrue(groups[0].isForNewComics)
        XCTAssertEqual(groups.count, 2)
        
    }
    
    func testAddingANewComic() {
        try! dataService.addNewComic(name: "Capitan America",
                                imageNames: ["01" , "02"],
                                thumbnailNames: ["01" , "02"],
                                to: nil)
        let req = NSFetchRequest<Comic>(entityName: "Comic")
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Comic.name) , "Capitan America")
        req.predicate = predicate
        
        let comics = try! mockManagedContext.fetch(req)
        XCTAssertTrue(comics.first!.ofComicGroup!.isForNewComics)
    }
    
    
    
    func printComics() {
        print("-------------Comics-----------")
        let fetchResultController = try! dataService.configureFetchResultController()
        print(fetchResultController.fetchedObjects ?? [])
    }
    
    
    func createFakeData() {
        
        
        let comic1 = Comic(context: mockManagedContext)
        comic1.name = "Batman"
        comic1.imageNames = ["01", "02", "03"]
        comic1.lastVisitedPage = 0
        comic1.thumbnailNames = ["01t", "02t", "03t"]
        comic1.id = UUID()
        
        let comic2 = Comic(context: mockManagedContext)
        comic2.name = "Superman"
        comic2.imageNames = ["01", "02", "03"]
        comic2.lastVisitedPage = 0
        comic2.thumbnailNames = ["01t", "02t", "03t"]
        comic2.id = UUID()
        
        let comic3 = Comic(context: mockManagedContext)
        comic3.name = "Wonder Woman"
        comic3.imageNames = ["01", "02", "03"]
        comic3.lastVisitedPage = 0
        comic3.thumbnailNames = ["01t", "02t", "03t"]
        comic3.id = UUID()
        
        let comic4 = Comic(context: mockManagedContext)
        comic4.name = "Joker"
        comic4.imageNames = ["01", "02", "03"]
        comic4.lastVisitedPage = 0
        comic4.thumbnailNames = ["01t", "02t", "03t"]
        comic4.id = UUID()
        

        let comicGroup1 = ComicGroup(context: mockManagedContext)
        comicGroup1.name = "New Comics"
        comicGroup1.isForNewComics = true
        comicGroup1.addToComics(comic1)
        comicGroup1.addToComics(comic2)
        comicGroup1.addToComics(comic3)
        comicGroup1.addToComics(comic4)
        comicGroup1.id = UUID()
        
        
        
        
        let comic5 = Comic(context: mockManagedContext)
        comic5.name = "HellBoy 01"
        comic5.imageNames = ["01", "02", "03"]
        comic5.lastVisitedPage = 0
        comic5.thumbnailNames = ["01t", "02t", "03t"]
        comic5.id = UUID()
        
        let comic6 = Comic(context: mockManagedContext)
        comic6.name = "HellBoy 02"
        comic6.imageNames = ["01", "02", "03"]
        comic6.lastVisitedPage = 0
        comic6.thumbnailNames = ["01t", "02t", "03t"]
        comic6.id = UUID()
        
        
        let comicGroup2 = ComicGroup(context: mockManagedContext)
        comicGroup2.name = "Hell Boy"
        comicGroup2.isForNewComics = false
        comicGroup2.addToComics(comic5)
        comicGroup2.addToComics(comic6)
        comicGroup2.id = UUID()
        
        let comic7 = Comic(context: mockManagedContext)
        comic7.name = "Deadpool"
        comic7.imageNames = ["01", "02", "03"]
        comic7.lastVisitedPage = 0
        comic7.thumbnailNames = ["01t", "02t", "03t"]
        comic7.id = UUID()
        
        
        let comicGroup3 = ComicGroup(context: mockManagedContext)
        comicGroup3.name = "Marvel"
        comicGroup3.isForNewComics = false
        comicGroup3.addToComics(comic7)
        comicGroup3.id = UUID()
        
        
        fakeComics.append(contentsOf: [comic1, comic2, comic3, comic4, comic5, comic6, comic7])
        fakeComicSections.append(contentsOf: [comicGroup1, comicGroup2, comicGroup3])
        
    }

}
