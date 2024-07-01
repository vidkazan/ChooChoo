//
//  SearchJourneyVM+feedback.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//

import Foundation
import Combine
import OSLog
import ChooNetworking

extension JourneyListViewModel {
	static func fetchJourneyList(
		dep : Stop,
		arr : Stop,
		time: Date,
		mode: LocationDirectionType,
		settings : JourneySettings
	) -> AnyPublisher<JourneyListDTO,ChooApiError> {
		var query = addJourneyListStopsQuery(dep: dep, arr: arr)
		query += addJourneyListTransfersQuery(settings: settings)
		query += addJourneyListTransportModes(settings: settings)
		query += addJourneyListTimeQuery(time: time, mode: mode)
		query += addJourneyOtherSettings(settings: settings)
		query += Query.queryItems(
			methods: [
				Query.remarks(showRemarks: true),
				Query.results(max: 5),
				Query.stopovers(isShowing: true)
			]
		)
		return ChooNetworking().fetch(JourneyListDTO.self,query: query, type: ChooRequest.journeys)
	}
	
	static func addJourneyListStopsQuery(dep : Stop,arr : Stop) -> [URLQueryItem] {
		var query : [URLQueryItem] = Constants.initialQuery
		switch dep.type {
		case .location:
			query += [
				Query.address(addr: dep.name).queryItem().departure(),
				Query.latitude(latitude: (String(dep.coordinates.latitude))).queryItem().departure(),
				Query.longitude(longitude: (String(dep.coordinates.longitude))).queryItem().departure()
			]
		case .pointOfInterest:
			guard let id = dep.stopDTO?.id else {
				Logger.fetchJourneyList.error("departure poi id is NIL")
				return query
			}
			
			query += [
				Query.poiId(poiId: id).queryItem().departure(),
				Query.latitude(latitude: (String(dep.coordinates.latitude))).queryItem().departure(),
				Query.longitude(longitude: (String(dep.coordinates.longitude))).queryItem().departure(),
				Query.poiName(poiName: "name").queryItem().departure()
			]
		case .stop,.station:
			guard let depStop = dep.stopDTO?.id else {
				Logger.fetchJourneyList.error("departure stop id is NIL")
				return query
			}
			query += Query.queryItems(methods: [
				Query.departureStopId(departureStopId: depStop)
			])
		}
		
		switch arr.type {
		case .location:
			query += [
				Query.address(addr: arr.name).queryItem().arrival(),
				Query.latitude(latitude: (String(arr.coordinates.latitude))).queryItem().arrival(),
				Query.longitude(longitude: (String(arr.coordinates.longitude))).queryItem().arrival(),
			]
		case .pointOfInterest:
			guard let id = arr.stopDTO?.id else {
				Logger.fetchJourneyList.error("arr pointOfInterest id is NIL")
				return query
			}
			query += [
				Query.poiId(poiId: id).queryItem().arrival(),
				Query.latitude(latitude: (String(arr.coordinates.latitude))).queryItem().arrival(),
				Query.longitude(longitude: (String(arr.coordinates.longitude))).queryItem().arrival(),
				Query.poiName(poiName: "name").queryItem().arrival()
			]
		case .stop,.station:
			guard let depStop = arr.stopDTO?.id else {
				Logger.fetchJourneyList.error("arr stop id is NIL")
				return query
			}
			query += Query.queryItems(methods: [
				Query.arrivalStopId(arrivalStopId: depStop)
			])
		}
		return query
	}
	
	
	static func addJourneyListTransfersQuery(settings : JourneySettings) -> [URLQueryItem] {
		switch settings.transferTime {
		case .direct:
			return Query.queryItems(methods: [
				Query.transfersCount(0)
			])
		case .time(minutes: let minutes):
			if let count = settings.transferCount.queryValue {
				return Query.queryItems(methods: [
					Query.transferTime(transferTime: minutes.rawValue),
					Query.transfersCount(count)
				])
			}
			return Query.queryItems(methods: [
				Query.transferTime(transferTime: minutes.rawValue)
			])
		}
	}
	static func addJourneyOtherSettings(settings : JourneySettings) -> [URLQueryItem] {
		return Query.queryItems(methods: [
			Query.accessibility(settings.accessiblity),
			Query.bike(settings.withBicycle),
			Query.startWithWalking(settings.startWithWalking),
			Query.walkingSpeed(settings.walkingSpeed)
		])
	}
	
	static func addJourneyListTimeQuery(time : Date, mode : LocationDirectionType) -> [URLQueryItem] {
		switch mode {
		case .departure:
			return Query.queryItems(methods: [
				Query.departureTime(departureTime: time)
			])
		case .arrival:
			return Query.queryItems(methods: [
				Query.arrivalTime(arrivalTime: time)
			])
		}
	}
	
	static func addJourneyListTransportModes(settings : JourneySettings) -> [URLQueryItem] {
		switch settings.transportMode {
		case .all:
			return []
		case .regional:
			return Query.queryItems(
				methods: [
					Query.national(icTrains: false),
					Query.nationalExpress(iceTrains: false),
					Query.regionalExpress(reTrains: false),
					Query.taxi(taxi: false)
				]
			)
		case .custom:
			let products = settings.customTransferModes
			return Query.queryItems(
				methods: [
					Query.national(icTrains: products.contains(.national)),
					Query.nationalExpress(iceTrains: products.contains(.nationalExpress)),
					Query.regionalExpress(reTrains: products.contains(.regionalExpress)),
					Query.regional(rbTrains: products.contains(.regional)),
					Query.suburban(sBahn: products.contains(.suburban)),
					Query.ferry(ferry: products.contains(.ferry)),
					Query.tram(tram: products.contains(.tram)),
					Query.taxi(taxi: products.contains(.taxi)),
					Query.subway(uBahn: products.contains(.subway)),
					Query.bus(bus: products.contains(.bus))
				]
			)
		}
	}
}

