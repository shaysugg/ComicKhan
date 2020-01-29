//
//  AppFileManagerTest.swift
//  coreTests
//
//  Created by Sha Yan on 1/26/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import UIKit
import CoreData

@testable import wutComicReader

class AppFileManagerTest: XCTestCase {
    
    
    
    var sut: AppFileManager!
    var persistantContainer : NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    
    let fileManager = FileManager.default
    
    struct ImageInfo {
        let name : String
        let path : String
    }

    //MARK:- initial functions
    
    override func setUp() {
        sut = AppFileManager()
        setupMockCoreData()
        creatTempDiractories()
        
    }

    override func tearDown() {
        sut = nil
        persistantContainer = nil
        managedObjectContext = nil
    }
    
    func creatTempDiractories(){
        let tempFromURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "from")
        let tempToURL = URL(fileURLWithPath:  NSTemporaryDirectory() + "to")
            try! fileManager.createDirectory(at: tempFromURL, withIntermediateDirectories: true, attributes: nil)
            try! fileManager.createDirectory(at: tempToURL, withIntermediateDirectories: true, attributes: nil)
        sut.userDiractory = tempFromURL
        sut.comicDirectory = tempToURL
    }
    
    
    func setupMockCoreData(){
        
        persistantContainer = makeMockPersistantContainer()
        persistantContainer.viewContext.automaticallyMergesChangesFromParent = true
        managedObjectContext = persistantContainer.newBackgroundContext()
        
        sut.managedContext = managedObjectContext
    }
    
    
    func makeMockPersistantContainer() -> NSPersistentContainer {
        
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!
        
        let container = NSPersistentContainer(name: "testPersistent", managedObjectModel: managedObjectModel )
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            
            if let err = error {
                fatalError(err.localizedDescription)
            }
        }
        
        return container
        
    }
    
    func flushData(){
        let request = NSFetchRequest<Comic>(entityName: "Comic")
        let results = try! managedObjectContext.fetch(request)
        for case let result as NSManagedObject in results {
            managedObjectContext.delete(result)
        }
        try! managedObjectContext.save()
    }
    
    
    
    
    //MARK:- test functions
    
    func testInitialValues(){
        XCTAssertNotNil(sut)
        XCTAssertNotNil(persistantContainer)
        XCTAssertNotNil(managedObjectContext)
    }
    
    func testComicWriteOnCoreData() {
        //given
        
        let testBundle = Bundle(for: type(of: self))
        
        let imagesInfos : [ImageInfo] = [
            ImageInfo(name: "01.png", path: testBundle.path(forResource: "01", ofType: "png")!),
            ImageInfo(name: "02.png", path: testBundle.path(forResource: "02", ofType: "png")!),
            ImageInfo(name: "03.png", path: testBundle.path(forResource: "03", ofType: "png")!)
            ]
        
        let imagesDir = sut.comicDirectory.appendingPathComponent("images")
        try! fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
        //copy to temp folder
        for image in imagesInfos {
            try! fileManager.copyItem(at: URL(fileURLWithPath: image.path), to: imagesDir.appendingPathComponent(image.name))
        }
        
        //when
        
        sut.writeNewComicsOnCoreData()
        
        //then
        
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
        
        let comics = try! managedObjectContext.fetch(fetchRequest)
        
//        print(comics)
//        XCTAssertFalse(comics.isEmpty)
        
        
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

