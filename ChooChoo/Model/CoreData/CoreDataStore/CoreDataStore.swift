//
//  CoreDataStore.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 07.01.24.
//

import Foundation
import CoreData
import CoreLocation

final class CoreDataStore : ObservableObject {
	var asyncContext: NSManagedObjectContext
	var user : CDUser? = nil

	init(container : NSPersistentContainer = PersistenceController.shared.container) {
		self.asyncContext = container.newBackgroundContext()
		self.asyncContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
	}
}

extension CoreDataStore {
	func saveAsyncContext(){
		do {
			try asyncContext.save()
			print("📗 > saved asyncContext")
		} catch {
			let nserror = error as NSError
			print("📕 > save asyncContext: ", nserror.description, nserror.userInfo)
		}
	}
}


// MARK: Entities enum
extension CoreDataStore {
	enum Entities {
		case user
		case locations(stop : Stop, user : CDUser)
		case journeys
		case recentSearches
		
		var type : NSManagedObject.Type {
			switch self {
			case .recentSearches:
				return CDRecentSearch.self
			case .user:
				return CDUser.self
			case .locations:
				return CDLocation.self
			case .journeys:
				return CDJourney.self
			}
		}
	}
}



enum CoreDataError : ChewError {
	static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
		return lhs.description == rhs.description
	}
	
	func hash(into hasher: inout Hasher) {
		switch self {
		case .failedToUpdateDatabase:
			break
		case .failedToAdd:
			break
		case .failedToDelete:
			break
		}
	}
	case failedToUpdateDatabase(type : NSManagedObject.Type)
	case failedToAdd(type : NSManagedObject.Type)
	case failedToDelete(type : NSManagedObject.Type)
	
	
	var description : String  {
		switch self {
		case .failedToUpdateDatabase(type: let type):
			return "failedToUpdateDatabase type: \(type)"
		case .failedToAdd(type: let type):
			return "failedToAddToDatabase type: \(type)"
		case .failedToDelete(type: let type):
			return "failedToAddToDelete type: \(type)"
		}
	}
}
