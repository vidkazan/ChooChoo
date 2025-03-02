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
	
    struct ApiDatav6dbtransportrest {
        struct Share {
            static let ghPageBase = "vidkazan.github.io"
            static let shareJourneyPath = "/choochooapp/#/journey"
        }
        
        
        static let urlBase = "v6.bvg.transport.rest"
		static let urlPathStops = "/stops/"
		static let urlPathDepartures = "/departures"
		static let urlPathLocations = "/locations"
		static let urlPathLocationsNearby = "/locations/nearby"
		static let urlPathJourneyList = "/journeys"
		static let urlPathTrip = "/trips"
		static let forPing = "/stops/8010159"
	}
    
    struct ApiDataIntBahnDe {
        struct Share {
            static let ghPageBase = "vidkazan.github.io"
            static let shareJourneyPath = "/choochooapp/#/journey"
        }
        
        
        static let urlBase = "int.bahn.de/web/api"
        static let urlPathStops = "/reiseloesung/orte"
        static let urlPathDepartures = "/reiseloesung/abfahrten"
        static let urlPathLocations = "/reiseloesung/orte"
        static let urlPathLocationsNearby = "/reiseloesung/orte/nearby"
        static let urlPathJourneyList = "/angebote/fahrplan"
        static let urlPathTrip = "/reiseloesung/fahrt"
        static let forPing = "/reiseloesung/orte?suchbegriff=Neuss+Hbf&typ=ALL&limit=10"
    }
}
