//
//  DataService.swift
//  wutComicReader
//
//  Created by Sha Yan on 4/22/20.
//  Copyright © 2020 wutup. All rights reserved.
//

import UIKit
import CoreData

class DataService {
    var managedContext: NSManagedObjectContext!
    var comicFetchResultController: NSFetchedResultsController<Comic>?
    var groupForNewComics: ComicGroup?
    
    init(managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.managedContext = managedContext
    }
    
    func configureFetchResultController() throws -> NSFetchedResultsController<Comic> {
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
        
        let basedOnIsInNewComicGroup = NSSortDescriptor(key: #keyPath(Comic.ofComicGroup.isForNewComics), ascending: false)
        let basedOnComicGroupName = NSSortDescriptor(key: #keyPath(Comic.groupName), ascending: true)
        let basedOnName = NSSortDescriptor(key: #keyPath(Comic.name), ascending: true)
        
        fetchRequest.sortDescriptors = [basedOnIsInNewComicGroup, basedOnComicGroupName , basedOnName]
        
        comicFetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: #keyPath(Comic.groupName), cacheName: nil)
        
        do {
            try comicFetchResultController?.performFetch()
        }catch let err {
            throw err
        }
        
        return comicFetchResultController!
    }
    
    
    func fetchComicGroups() throws -> [ComicGroup] {
        let request = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
        do {
            let groups = try managedContext.fetch(request)
            return groups
        }catch let err {
            throw err
        }
    }
    
    func deleteComicFromCoreData(withName name: String) throws {
        
        guard let context = managedContext else { return }
        
        let deletereq = NSFetchRequest<Comic>(entityName: "Comic")
        let predict = NSPredicate(format: "%K == %@", #keyPath(Comic.name) , name)
        deletereq.predicate = predict
        
        
        guard let comics = try? context.fetch(deletereq) else { return }
        for comic in comics {
            context.delete(comic)
        }
        do {
            try context.save()
        }catch let err{
            throw err
        }
    }
    
    func createANewComicGroup(name: String, comics: [Comic]?) throws {
        
        let newComicGroup = ComicGroup(context: managedContext)
        newComicGroup.id = UUID()
        newComicGroup.isForNewComics = false
        newComicGroup.name = name
        
        if let _ = comics {
            newComicGroup.addToComics(NSOrderedSet(array: comics!))
            
            for comic in comics! {
                comic.groupName = name
            }
        }
        
        do {
            try managedContext.save()
        }catch let err {
            throw err
        }
        
    }
    
    func createGroupForNewComics() throws {
        
        do {
            let newComicGroup = ComicGroup(context: managedContext)
            newComicGroup.id = UUID()
            newComicGroup.isForNewComics = true
            newComicGroup.name = "New Comics"
            
            try managedContext.save()
        }catch let err {
            throw err
        }
        
    }
    
    func changeGroupOf(comics: [Comic], to group: ComicGroup) throws {
        let set = NSOrderedSet(array: comics)
        group.addToComics(set)
        
        for comic in comics {
            comic.groupName = group.name
        }
        
        do{
            try managedContext.save()
        }catch let err{
            throw err
        }
    }
    
    func deleteEmptyGroups() throws {
        
        let fetchRequest = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
        
        do{
            let allGroups = try managedContext.fetch(fetchRequest)
            
            let emptyGroups = allGroups.filter({
                $0.comics?.count == 0 && !$0.isForNewComics
            })
            for comic in emptyGroups {
                managedContext.delete(comic)
            }
            
            
            try managedContext.save()
        }catch let err {
            throw err
        }
        
    }
    
    func addNewComic(name: String, imageNames: [String], thumbnailNames: [String], to comicGroup: ComicGroup?) throws {
        
        do {
            try fetchGroupForNewComics()
            let comic = Comic(context: managedContext)
            comic.id = UUID()
            comic.name = name
            comic.lastVisitedPage = 0
            comic.imageNames = imageNames
            comic.thumbnailNames = thumbnailNames
            if let group = comicGroup {
                group.addToComics(comic)
                comic.groupName = group.name
            }else{
                groupForNewComics?.addToComics(comic)
                comic.groupName = groupForNewComics?.name
            }
            
            try managedContext.save()
        }catch let err {
            throw err
        }
        
    }
    
    private func fetchGroupForNewComics() throws -> ComicGroup? {
        let request = NSFetchRequest<ComicGroup>(entityName: "ComicGroup")
        let predicate = NSPredicate(format: "%K == true", #keyPath(ComicGroup.isForNewComics))
        request.predicate = predicate
        
        do{
            groupForNewComics = try managedContext.fetch(request).first
            return groupForNewComics
        }catch let err {
            throw err
        }
    }
    
    func saveLastPageOf(comic: Comic, lastPage: Int) throws {
        comic.lastVisitedPage = Int16(lastPage)
        do {
            try managedContext.save()
        }catch let err{
            throw err
        }
    }
    
    func comicAlreadyExistedInCoreData(withName comicname: String) -> Bool{
    
        let fetchRequest = NSFetchRequest<Comic>(entityName: "Comic")
        fetchRequest.predicate = NSPredicate(format: "name == %@", comicname)
        
        do{
            let sameComicsName = try managedContext.fetch(fetchRequest)
            return !sameComicsName.isEmpty
        }catch{
            return false
        }
    }
    
    
}
