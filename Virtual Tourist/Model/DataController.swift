//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
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
            completion?()
        }
    }
}

