//
//  DatabaseService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 28/11/2025.
//

import Foundation
import CoreData

class DatabaseManager {
    static let instance = DatabaseManager()
    static let previewInstance = DatabaseManager(inMemory: true)
    
    private let container: NSPersistentContainer
    let context: NSManagedObjectContext
    private let containerName: String = "CryptoCoinContainer"
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: containerName)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core data fatal error: \(error.localizedDescription), \(error.userInfo)")
            }
        }
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        do {
            try context.save()
        } catch let error {
            print("Error saving: \(error.localizedDescription)")
        }
    }
}
