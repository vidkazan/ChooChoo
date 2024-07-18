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

//func constructTransferViewData(fromLeg : LegDTO, toLeg : LegDTO) -> LegViewData? {
//	let first = TimeContainer(
//		plannedDeparture: fromLeg.plannedArrival,
//		plannedArrival: fromLeg.plannedArrival,
//		actualDeparture: fromLeg.arrival,
//		actualArrival: fromLeg.arrival,
//		cancelled: nil
//	)
//	let last = TimeContainer(
//		plannedDeparture: toLeg.plannedDeparture,
//		plannedArrival: toLeg.plannedDeparture,
//		actualDeparture: toLeg.departure,
//		actualArrival: toLeg.departure,
//		cancelled: nil
//	)
//	let container = TimeContainer(
//		plannedDeparture: fromLeg.plannedArrival,
//		plannedArrival: toLeg.plannedDeparture,
//		actualDeparture: fromLeg.arrival,
//		actualArrival: toLeg.departure,
//		cancelled: nil
//	)
//	
//	 let direction = StopViewData(
//		stopId: toLeg.origin?.id,
//			  name: toLeg.origin?.name ?? "to",
//			  time: last,
//			  type: .transfer,
//			  coordinates: Coordinate(
//				  latitude: toLeg.origin?.latitude ?? toLeg.origin?.location?.latitude ?? 0,
//				  longitude: toLeg.origin?.longitude ?? toLeg.origin?.location?.longitude ?? 0
//			  )
//		  )
//	let res = LegViewData(
//		isReachable: fromLeg.reachable ?? true,
//		legType: .transfer,
//		tripId: UUID().uuidString,
//		direction: Prognosed(actual: direction.name,planned: direction.name),
//		legTopPosition: 0,
//		legBottomPosition: 0,
//		delayedAndNextIsNotReachable: false,
//		remarks: [],
//		legStopsViewData: [
//			StopViewData(
//				stopId: fromLeg.destination?.id,
//				name: fromLeg.destination?.name ?? "from",
//				time: first,
//				type: .transfer,
//				coordinates: Coordinate(
//					latitude: fromLeg.destination?.latitude ?? fromLeg.destination?.location?.latitude ?? 0,
//					longitude: fromLeg.destination?.longitude ?? fromLeg.destination?.location?.longitude ?? 0
//				)
//			),
//			direction
//		],
//		footDistance: 0,
//		lineViewData: LineViewData(type: .transfer, name: "transfer", shortName: "transfer", id: nil),
//		progressSegments: Segments(
//			segments: [
//				Segments.SegmentPoint(
//					time: container.timestamp.departure.actual ?? 0,
//					height: 0
//				),
//				Segments.SegmentPoint(
//					time: container.timestamp.arrival.actual ?? 0,
//					height: StopOverType.transfer.viewHeight
//				)
//			],
//			heightTotalCollapsed: StopOverType.transfer.viewHeight,
//			heightTotalExtended: StopOverType.transfer.viewHeight
//		),
//		time: container,
//		polyline: nil,
//		legDTO : nil
//	)
//	return res
//}

func constructTransferViewData(fromLeg : LegViewData, toLeg : LegViewData) -> LegViewData? {
	let first = TimeContainer(
		plannedDeparture: fromLeg.legDTO?.plannedArrival,
		plannedArrival: fromLeg.legDTO?.plannedArrival,
		actualDeparture: fromLeg.legDTO?.arrival,
		actualArrival: fromLeg.legDTO?.arrival,
		cancelled: fromLeg.time.arrivalStatus == .cancelled
	)
	let last = TimeContainer(
		plannedDeparture: toLeg.legDTO?.plannedDeparture,
		plannedArrival: toLeg.legDTO?.plannedDeparture,
		actualDeparture: toLeg.legDTO?.departure,
		actualArrival: toLeg.legDTO?.departure,
		cancelled: toLeg.time.departureStatus == .cancelled
	)
	let container = TimeContainer(
		plannedDeparture: fromLeg.legDTO?.plannedArrival,
		plannedArrival: toLeg.legDTO?.plannedDeparture,
		actualDeparture: fromLeg.legDTO?.arrival,
		actualArrival: toLeg.legDTO?.departure,
		cancelled: fromLeg.time.arrivalStatus == .cancelled && toLeg.time.departureStatus == .cancelled
	)
	let res = LegViewData(
		isReachable: fromLeg.isReachable,
		legType: .transfer,
		tripId: UUID().uuidString,
		direction: fromLeg.direction,
		legTopPosition: 0,
		legBottomPosition: 0,
		delayedAndNextIsNotReachable: false,
		remarks: [],
		legStopsViewData: [
			StopViewData(
				stopId: fromLeg.legDTO?.destination?.id,
				name: fromLeg.legDTO?.destination?.name ?? "from",
				time: first,
				type: .transfer,
				coordinates: Coordinate(
					latitude: fromLeg.legDTO?.destination?.latitude ?? fromLeg.legDTO?.destination?.location?.latitude ?? 0,
					longitude: fromLeg.legDTO?.destination?.longitude ?? fromLeg.legDTO?.destination?.location?.longitude ?? 0
				)
			),
			StopViewData(
				stopId: toLeg.legDTO?.origin?.id,
				name: toLeg.legDTO?.origin?.name ?? "to",
				time: last,
				type: .transfer,
				coordinates: Coordinate(
					latitude: toLeg.legDTO?.origin?.latitude ?? toLeg.legDTO?.origin?.location?.latitude ?? 0,
					longitude: toLeg.legDTO?.origin?.longitude ?? toLeg.legDTO?.origin?.location?.longitude ?? 0
				)
			)
		],
		footDistance: 0,
		lineViewData: LineViewData(type: .transfer, name: "transfer", shortName: "transfer", id: nil),
		progressSegments: Segments(
			segments: [
				Segments.SegmentPoint(
					time: container.timestamp.departure.actual ?? 0,
					height: 0
				),
				Segments.SegmentPoint(
					time: container.timestamp.arrival.actual ?? 0,
					height: StopOverType.transfer.viewHeight
				)
			],
			heightTotalCollapsed: StopOverType.transfer.viewHeight,
			heightTotalExtended: StopOverType.transfer.viewHeight
		),
		time: container,
		polyline: nil,
		legDTO : nil
	)
	return res
}
