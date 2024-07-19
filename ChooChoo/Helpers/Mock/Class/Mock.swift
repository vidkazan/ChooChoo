//
//  Mock.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 28.11.23.
//

import Foundation
import UIKit
import OSLog

enum Mock {
	static let trip = TripMockFiles.self
	static let journeys = JourneyMockFiles.self
	static let journeyList = JourneyListMockFiles.self
	static let stopDepartures = StopDeparturesMockFiles.self
	static let stops = StopsMockFiles.self
}

struct StopDeparturesMockFiles {
	static let type = MockService<StopTripsDTO>.self
	
	static let stopDeparturesNeussHbf = type.init(
		"stopDeparturesNeussHbf"
	)
}

struct StopsMockFiles {
	static let type = MockService<[StopDTO]>.self
	
	static let stopByK = type.init(
		"stops-by-K"
	)
	static let stopByD = type.init(
		"stops-by-D"
	)
}

struct TripMockFiles {
	static let type = MockService<TripDTO>.self
	
	static let cancelledMiddleStopsRE6NeussMinden = type.init(
		"cancelledMiddleStops-Trip-RE6-Neuss-Minden"
	)
	static let cancelledFirstStopRE11DussKassel = type.init(
		"cancelledFirstStop-Trip-RE11-Duss-Kassel"
	)
	static let cancelledLastStopRE11DussKassel = type.init(
		"cancelledLastStop-Trip-RE11-Duss-Kassel"
	)
	static let RE6NeussMinden = type.init(
		"re6-Neuss-Minden"
	)
}

struct AlternativesJourneyMockFiles{
	static let type = MockService<JourneyWrapper>.self
	
	static let alternativesJourneyNeussWolfsburg = type.init(
		"alternatives-journey-Neuss-Wolfsburg"
	)
	static let alternativesJourneyNeussWolfsburgS1FirstStopCancelled = type.init(
		"alternatives-journey-Neuss-Wolfsburg-S1FirstStopCancelled"
	)
	static let alternativesJourneyNeussWolfsburgS1LastStopCancelled = type.init(
		"alternatives-journey-Neuss-Wolfsburg-S1LastStopCancelled"
	)
	static let alternativesJourneyNeussWolfsburgRE6LateAndNextIsNotAvailable = type.init(
		"alternatives-journey-Neuss-Wolfsburg-RE6LateAndNextIsNotAvailable"
	)
	static let oneLegFirstStopIsCancelled = type.init(
		"oneLeg-firstStopIsCancelled"
	)
}

struct JourneyMockFiles{
	static let type = MockService<JourneyWrapper>.self
	
	static let alternativasMoks = AlternativesJourneyMockFiles.self
	
	static let journeyNeussWolfsburg = type.init(
		"journey-Neuss-Wolfsburg"
	)
	static let journeySyltWien = type.init(
		"journeySylt-Wien"
	)
	static let journeyNeussWolfsburgFirstCancelled = type.init(
		"journey-Neuss-Wolfsburg-First-Cancelled"
	)
	static let journeyNeussWolfsburgMissedConnection = type.init(
		"journey-Neuss-Wolfsburg-missedConnection"
	)
	static let userLocationToStation = type.init(
		"userLocationToStation"
	)
}

struct JourneyListMockFiles {
	static let type = MockService<JourneyListDTO>.self
	
	static let journeyNeussWolfsburg = type.init(
		"neussWolfsburg"
	)
	static let journeyListPlaceholder = type.init(
		"placeholder"
	)
}

class MockService<T : Decodable> {
	let rawData : Data?
	let decodedData : T?
	
	required init(_ assetName : String) {
		self.rawData = NSDataAsset(name: assetName)?.data
		self.decodedData = Self.decodedData(rawData: rawData)
	}
	
	static func decodedData<DTO : Decodable>(rawData : Data?) -> DTO? {
		guard let data = rawData else {
			Logger.mockService.warning("decodeData: data is nil")
			return nil
		}
		do {
			let res = try JSONDecoder().decode(DTO.self, from: data)
			return res
		}
		catch {
			Logger.mockService.error("mock JSON decoder: \(error)")
			return nil
		}
	}
}
