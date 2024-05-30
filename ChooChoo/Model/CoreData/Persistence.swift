//
//  Persisence.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.11.23.
//

import Foundation
import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  static let preview = PersistenceController(inMemory: true)

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
	container = NSPersistentContainer(name: "Model")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
					fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
	}
}
