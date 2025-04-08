//
//  CoreDataManager.swift
//  MusicApp
//
//  Created by Никита Агафонов on 07.04.2025.
//

import CoreData

final class CoreDataManager {
    private let modelName = "PlaylistModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            try? context.save()
        }
    }
}
