//
//  CoreDataStack.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 05.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataStack: NSObject {
    
    let imageService = ImageService()
    
    static let sharedInstance = CoreDataStack()
    private override init() {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Restaurants")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func clearData(entity: String) {
        do {
            
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                    saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func clearAllData(){
        
        clearData(entity: "Restaurant")
        
        if let pictures = getAllDataFromEntity(entity: "Picture"){
            for picture in pictures{
                let pic = picture as! Picture
                imageService.delete(fileName: pic.file_name!)
                
            }
        }
        
        clearData(entity: "Picture")
        
    }
    
    func getAllDataFromEntity(entity: String) ->  [NSManagedObject]? {
        
      
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do{
            let searchresults = try persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject]
            return searchresults
            }catch let error{
                    print(error)
            
                            }
        
        return nil
        
    }
    
    
    func clearDataWithAtributte(entity: String, attribute: String, value: String){
        let format: String = attribute + " == %@"
        
        do {
            
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            fetchRequest.predicate = NSPredicate(format: format, value)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
        
    }
    
    func returnUniqueIDPicture(restaurantName: String) -> String?{
        
        let fetchRequest:NSFetchRequest<Picture> = Picture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", restaurantName)
        
        do{
            let searchresults = try persistentContainer.viewContext.fetch(fetchRequest)
            if searchresults.count > 0{
                let picture = searchresults[0]
                return picture.file_name
            }else{
                return nil
                }
        }catch let error{
            print(error)
            return nil
        }

        
    }
    
}



extension CoreDataStack {
    
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}

