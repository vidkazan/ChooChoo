//
//  constructJourneyList+Leg.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation
import OSLog

extension StopTripDTO {
	func legViewData(type : LocationDirectionType) -> LegViewData? {
		do {
			return try legViewDataThrows(type: type)
		} catch let err{
			if let err = err as? DataError {
				Self.error(err.localizedDescription)
			} else {
				Self.error(err.localizedDescription)
			}
			return nil
		}
	}
	func legViewDataThrows(type : LocationDirectionType) throws -> LegViewData {
		let container = {
			switch type {
			case .departure:
				return TimeContainer(
					plannedDeparture: plannedWhen,
					plannedArrival: nil,
					actualDeparture: when,
					actualArrival: nil,
					cancelled: nil
				)
			case .arrival:
				return TimeContainer(
					plannedDeparture: nil,
					plannedArrival: plannedWhen,
					actualDeparture: nil,
					actualArrival: when,
					cancelled: nil
				)
			}
		}()
		
		guard container.timestamp.departure.planned != container.timestamp.arrival.planned else {
			throw DataError.nilValue(type: "\(origin?.name ?? "origin is empty") \(destination?.name  ?? "destination is empty"): leg duration is 0")
		}

		guard let tripId = tripId else  {
			throw DataError.nilValue(type: "tripId")
		}
		
		let stops : [StopViewData] = {
			// arrival type
			if let origin = origin {
				return [
					StopViewData(
						id: origin.id,
						locationCoordinates: Coordinate(latitude: origin.latitude ?? 0, longitude: origin.longitude ?? 0),
						name: origin.name ?? "",
						platforms: .init(
							departure: .init(),
							arrival: .init()
						),
//						departurePlatform: .init(),
//						arrivalPlatform: .init(),
						time: .init(),
						stopOverType: .origin
					),
					StopViewData(
						id: stop?.id,
						locationCoordinates: Coordinate(latitude: stop?.latitude ?? 0, longitude: stop?.longitude ?? 0),
						name: stop?.name ?? "",
						platforms: .init(
							departure: .init(),
							arrival: .init(actual: platform,planned: plannedPlatform)
						),
//						departurePlatform: .init(),
//						arrivalPlatform: .init(actual: platform,planned: plannedPlatform),
						time: container,
						stopOverType: .destination
					)
				]
			}
			// departure type
			if let destination = destination {
				return [
					StopViewData(
						id: stop?.id,
						locationCoordinates: Coordinate(latitude: stop?.latitude ?? 0, longitude: stop?.longitude ?? 0),
						name: stop?.name ?? "",
						platforms: .init(
							departure: .init(actual: platform,planned: plannedPlatform),
							arrival: .init()
						),
//						departurePlatform: .init(actual: platform,planned: plannedPlatform),
//						arrivalPlatform: .init(),
						time: container,
						stopOverType: .origin
					),
					StopViewData(
						id: destination.id,
						locationCoordinates: Coordinate(latitude: destination.latitude ?? 0, longitude: destination.longitude ?? 0),
						name: destination.name ?? "",
						platforms: .init(
							departure: .init(),
							arrival: .init()
						),
//						departurePlatform: .init(),
//						arrivalPlatform: .init(),
						time: .init(),
						stopOverType: .destination
					)
				]
			}
			return []
		}()
		
	
		var remarksUnwrapped = [RemarkViewData]()
		if let remarks = remarks {
			remarksUnwrapped = remarks.compactMap({$0.viewData()})
		}
		
		let res = LegViewData(
			isReachable: true,
			legType: .line,
			tripId: tripId,
			direction: direction ?? "direction",
			legTopPosition: 0,
			legBottomPosition: 0,
			delayedAndNextIsNotReachable: nil,
			remarks: remarksUnwrapped,
			legStopsViewData: stops,
			footDistance: 0,
			lineViewData: constructLineViewData(
				product: line?.product ?? "",
				name: line?.name ?? "",
				productName: line?.productName ?? "",
				legType: .line
			),
			progressSegments: .init(
				segments: [],
				heightTotalCollapsed: 0,
				heightTotalExtended: 0
			),
			time: container,
			polyline: nil,
			legDTO : nil
		)
		return res
	}
}

extension LegDTO {
	func legViewData(firstTS: Date?, lastTS: Date?, legs : [LegDTO]?) -> LegViewData? {
		do {
			return try legViewDataThrows(firstTS: firstTS, lastTS: lastTS, legs: legs)
		} catch let err {
			if let err = err as? DataError {
				Self.error(err.localizedDescription)
			} else {
				Self.error(err.localizedDescription)
			}
			return nil
		}
	}
	
	func legViewDataThrows(firstTS: Date?, lastTS: Date?, legs : [LegDTO]?) throws -> LegViewData {
		let container = TimeContainer(
			plannedDeparture: plannedDeparture,
			plannedArrival: plannedArrival,
			actualDeparture: departure,
			actualArrival: arrival,
			cancelled: nil
		)
		
		guard container.timestamp.departure.planned != container.timestamp.arrival.planned else {
			throw DataError.nilValue(type: "\(origin?.name ?? "origin is empty") \(destination?.name  ?? "destination is empty"): leg duration is 0")
		}
		
		guard
			let plannedDeparturePosition = getTimeLabelPosition(
				firstTS: firstTS,
				lastTS: lastTS,
				currentTS: container.date.departure.planned
			),
			let plannedArrivalPosition = getTimeLabelPosition(
				firstTS: firstTS,
				lastTS: lastTS,
				currentTS: container.date.arrival.planned
			) else {
			throw DataError.nilValue(type: "plannedArrivalPosition or plannedDeparturePosition")
		}
		
		guard let tripId = walking == true ? UUID().uuidString : tripId else {
			throw DataError.nilValue(type: "tripId")
		}
		
		
		let actualDeparturePosition = getTimeLabelPosition(
			firstTS: firstTS,
			lastTS: lastTS,
			currentTS: container.date.departure.actual
		) ?? 0
		
		let actualArrivalPosition = getTimeLabelPosition(
			firstTS: firstTS,
			lastTS: lastTS,
			currentTS: container.date.arrival.actual
		) ?? 0
		
		let stops = stopViewData(type: constructLegType(leg: self, legs: legs))
		let segments = segments(from: stops)
		var remarksUnwrapped = [RemarkViewData]()
		if let remarks = remarks {
			remarksUnwrapped = remarks.compactMap({$0.viewData()})
		}
		
		let legType = constructLegType(leg: self, legs: legs)
		
		let res = LegViewData(
			isReachable: stops.first?.cancellationType() != .fullyCancelled && stops.last?.cancellationType() != .fullyCancelled,
			legType: legType,
			tripId: tripId,
			direction: direction ?? "direction",
			legTopPosition: max(plannedDeparturePosition,actualDeparturePosition),
			legBottomPosition: max(plannedArrivalPosition,actualArrivalPosition),
			delayedAndNextIsNotReachable: nil,
			remarks: remarksUnwrapped,
			legStopsViewData: stops,
			footDistance: distance ?? 0,
			lineViewData: constructLineViewData(
				product: line?.product ?? "",
				name: line?.name ?? "",
				productName: line?.productName ?? "",
				legType: legType
			),
			progressSegments: segments,
			time: container,
			polyline: polyline,
			legDTO : self
		)
		return res
	}
}
func currentLegIsNotReachable(currentLeg: LegViewData?, previousLeg: LegViewData?) -> Bool? {
	guard let currentLeg = currentLeg?.time.timestamp.departure.actual,
			let previousLeg = previousLeg?.time.timestamp.arrival.actual else { return nil }
	return previousLeg > currentLeg
}
