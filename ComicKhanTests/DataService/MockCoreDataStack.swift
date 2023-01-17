//
//  MockCoreDataStack.swift
//  ComicKhanTests
//
//  Created by Sha Yan on 4/25/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import XCTest
import CoreData

func createMockManagedContext() -> NSManagedObjectContext? {
    
    //data module
    guard let modelURL = Bundle.main.url(forResource: "coredata", withExtension: "momd") else {
        XCTFail("object model not exist!")
        return nil
    }
    guard let objectModel = NSManagedObjectModel(contentsOf: modelURL) else {
        XCTFail("can't establish object model based on given url!")
        return nil
    }
    
    //cordinator
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
    
    do {
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    }catch {
        XCTFail("can't load persistant store")
    }
    
    //nsmanagedcontext
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    
    return context
}

