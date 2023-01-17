//
//  Comic+CoreDataProperties.swift
//  
//
//  Created by Sha Yan on 3/11/20.
//
//

import Foundation
import CoreData


extension Comic {
    @NSManaged public var id: UUID
    @NSManaged public var imageNames: [String]
    @NSManaged public var lastVisitedPage: Int16
    @NSManaged public var name: String
    @NSManaged public var thumbnailNames: [String]
    @NSManaged public var ofComicGroup: ComicGroup?
    @NSManaged public var groupName: String
    
    static var entityName: String = "Comic"
   
}


extension Comic: CustomStringConvertible {
    override var description: String {
        return """
        name : \(name)
        pageCount: \(imageNames.count ?? 0)
        comic group: \(ofComicGroup)
        """
    }
    
}
