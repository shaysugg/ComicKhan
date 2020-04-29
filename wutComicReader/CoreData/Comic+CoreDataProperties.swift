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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comic> {
        return NSFetchRequest<Comic>(entityName: "Comic")
    }

    @NSManaged public var id: UUID
    @NSManaged public var imageNames: [String]
    @NSManaged public var lastVisitedPage: Int16
    @NSManaged public var name: String
    @NSManaged public var thumbnailNames: [String]
    @NSManaged public var ofComicGroup: ComicGroup?

}


extension Comic: NSObjcet {
    override var description: String {
        return """
        name : \(name)
        pageCount: \(imageNames.count ?? 0)
        comic group: \(ofComicGroup)
        """
    }
    
    static var entityName: String {
        return "Comic"
    } 
}
