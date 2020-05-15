//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 12/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//


import Foundation
import CoreData

class DataController {
    
    lazy var persistentContainer : NSPersistentContainer = {
          return NSPersistentContainer(name: "Virtual_Tourist")
    }()
    
    var viewContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load( completion:( () -> Void )? = nil ){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            //self.autoSaveViewContext(10)
            completion?()
        }
    }
}


extension DataController{
    func autoSaveViewContext(_ interval : TimeInterval = 30){
        print("Autosaving")
        guard interval > 0 else { return }
        if viewContext.hasChanges {
        try? viewContext.save()
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval)
            }
        }
    }
}
