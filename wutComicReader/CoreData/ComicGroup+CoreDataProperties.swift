//
//  ComicGroup+CoreDataProperties.swift
//  
//
//  Created by Sha Yan on 12/22/19.
//
//

import Foundation
import CoreData


extension ComicGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComicGroup> {
        return NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
    }

    @NSManaged public var name: String?
    @NSManaged public var comics: NSSet?

}

// MARK: Generated accessors for comics
extension ComicGroup {

    @objc(addComicsObject:)
    @NSManaged public func addToComics(_ value: Comic)

    @objc(removeComicsObject:)
    @NSManaged public func removeFromComics(_ value: Comic)

    @objc(addComics:)
    @NSManaged public func addToComics(_ values: NSSet)

    @objc(removeComics:)
    @NSManaged public func removeFromComics(_ values: NSSet)

}
