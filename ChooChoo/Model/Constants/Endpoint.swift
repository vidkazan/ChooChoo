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
	
	static let navigationTitle = "Choo Choo"
	
	struct ApiData {
        struct Share {
            static let ghPageBase = "vidkazan.github.io"
            static let shareJourneyPath = "/choochooapp/#/journey"
        }
        
        
		static let urlBase = "v6.db.transport.rest"
		static let urlPathStops = "/stops/"
		static let urlPathDepartures = "/departures"
		static let urlPathLocations = "/locations"
		static let urlPathLocationsNearby = "/locations/nearby"
		static let urlPathJourneyList = "/journeys"
		static let urlPathTrip = "/trips"
		static let forPing = "/stops/8010159"
	}
}
