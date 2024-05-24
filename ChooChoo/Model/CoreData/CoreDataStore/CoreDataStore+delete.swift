//
//  CoreDataStore.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 07.01.24.
//

import Foundation
import CoreData
import CoreLocation
import OSLog

// MARK: remove
extension CoreDataStore {
	func deleteJourneyIfFound(id : Int64) -> Bool {
		var result = false
		if let objects = self.fetchJourneys() {
			 asyncContext.performAndWait {
				if let res = objects.first(where: { obj in
					return obj.id == id
				}) {
					self.asyncContext.delete(res)
					self.saveAsyncContext()
					result = true
				} else {
					Logger.coreData.error("\(#function): not found")
				}
			}
		} else {
			Logger.coreData.error("\(#function): fetch failed")
		}
		return result
	}
	
	func deleteRecentLocationIfFound(name : String) -> Bool {
		var result = false
		
		if let objects = self.fetch(CDLocation.self) {
			 asyncContext.performAndWait {
				if let objects = objects.first(where: { obj in
					return obj.name == name
				}) {
					self.asyncContext.delete(objects)
					self.saveAsyncContext()
					result = true
				}
			}
		}
		return result
	}
	
	func deleteRecentSearchIfFound(id : String) -> Bool {
		var result = false
		if let objects = self.fetch(CDRecentSearch.self) {
			 asyncContext.performAndWait {
				if let res = objects.first(where: { obj in
					return obj.id == id
				}) {
					self.asyncContext.delete(res)
					self.saveAsyncContext()
					result = true
				}
			}
		}
		return result
	}
}
