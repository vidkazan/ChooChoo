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
import FcodyCoreData

// MARK: Fetch
extension ChooDataStore {
	func fetchUser() -> CDUser? {
		let user = self.fetchOrCreateUser()?.first
		self.user = user
		return user
	}
	
	private func fetchOrCreateUser() -> [CDUser]? {
		if let res = fetch(CDUser.self), !res.isEmpty {
			return res
		}
		 asyncContext.performAndWait {
			 self.user = self.asyncContext.createManagedObject(CDUser.self)
		}
		return fetch(CDUser.self)
	}
	
	func fetchAppSettings() -> AppSettings? {
		var res : AppSettings?
		
		asyncContext.performAndWait {
			let settings = user?.appSettings
			guard let settings = settings else {
				return
			}
			res = try? JSONDecoder().decode(AppSettings.self, from: settings)
		}
		return res
	}
	
	func fetchSettings() -> JourneySettings? {
		var settings : Data?
		
		asyncContext.performAndWait {
			settings = user?.journeySettings
		}
		
		if let settings = settings {
			return try? JSONDecoder().decode(JourneySettings.self, from: settings)
		}
		return nil
	}
	
	func fetchLocations() -> [Stop]? {
		var stops = [Stop]()
		if let chewStops = fetch(CDLocation.self) {
			asyncContext.performAndWait {
				chewStops.forEach {
					if $0.user != nil {
						stops.append($0.stop())
					}
				}
			}
			return stops
		}
		return nil
	}
	
	func fetchRecentSearches() -> [RecentSearchesViewModel.RecentSearch]? {
		if let res = fetch(CDRecentSearch.self)  {
			var stops = [RecentSearchesViewModel.RecentSearch]()
			asyncContext.performAndWait {
				res.forEach {
					if
						let depArrStops = try? JSONDecoder().decode(DepartureArrivalPairStop.self, from: $0.depArrStops),
						let ts = $0.searchDate?.timeIntervalSince1970 {
							stops.append(RecentSearchesViewModel.RecentSearch(
								stops: depArrStops,
								searchTS: ts
							))
					}
				}
			}
			return stops
		}
		return nil
	}
	
	func fetchJourneys() -> [CDJourney]? {
		fetch(CDJourney.self)
	}
}
