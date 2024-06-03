//
//  Constans.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import SwiftUI

struct Constants {
	static let initialQuery : [URLQueryItem] = [
		Query.language(
			language: Locale.current.languageCode ?? "de"
		)
		.queryItem()
	]
	
	static let navigationTitle = {
		#if DEBUG
				return GitBranch.current ?? "main"
		#else
				return "Choo Choo"
		#endif
	}()
	
	struct apiData {
		static let urlBase = "v6.db.transport.rest"
		static let urlPathStops = "/stops/"
		static let urlPathDepartures = "/departures"
		static let urlPathLocations = "/locations"
		static let urlPathLocationsNearby = "/locations/nearby"
		static let urlPathJourneyList = "/journeys"
		static let urlPathTrip = "/trips"
	}
}
