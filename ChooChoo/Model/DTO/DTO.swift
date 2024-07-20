//
//  DTO.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import SwiftUI
import CoreLocation

struct Coordinate: Hashable, Codable {
	let latitude, longitude: Double
	
	init() {
		self.latitude = 0
		self.longitude = 0
	}
	
	init(_ coordinate: CLLocationCoordinate2D) {
		self.latitude = Double(coordinate.latitude)
		self.longitude = Double(coordinate.longitude)
	}
	init(latitude : Double ,longitude : Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
	var cllocationcoordinates2d : CLLocationCoordinate2D {
		.init(latitude: latitude, longitude: longitude)
	}
	var cllocation : CLLocation {
		.init(latitude: latitude, longitude: longitude)
	}
}

enum StopOverType : String,Hashable, CaseIterable, Codable {
	case origin
	case stopover
	case destination
	case footTop
	case footMiddle
	case footBottom
	case transfer
	
	func platform(stopOver : StopViewData) -> Prognosed<String>? {
		switch self {
		case .stopover:
			return stopOver.platforms.departure.actual == nil ? stopOver.platforms.arrival : stopOver.platforms.departure
		case .destination,.footBottom:
			return stopOver.platforms.arrival
		case .footTop,.origin,.footMiddle,.transfer:
			return stopOver.platforms.departure
		}
	}
	
	func timeLabelViewTime(tsContainer : TimeContainer.DateTimeContainer) -> Prognosed<Date> {
		switch self {
		case .destination, .footBottom:
			return tsContainer.arrival
		case .stopover:
			return tsContainer.departure.actual == nil ? tsContainer.arrival : tsContainer.departure
		default:
			return tsContainer.departure
		}
	}
	
	func timeLabelViewDelayStatus(time : TimeContainer) -> TimeContainer.DelayStatus {
		switch self {
		case .destination, .footBottom:
			return time.arrivalStatus
		case .stopover:
			if time.departureStatus == .cancelled {
				return time.arrivalStatus
			}
			return time.departureStatus
		default:
			return time.departureStatus
		}
	}
	
	var showBadgesOnLegStopView : Bool {
		switch self {
		case .origin:
			return true
		default:
			return false
		}
	}
	
	var timeLabelCornerRadius : CGFloat {
		switch self {
		case .stopover:
			return 5
		default:
			return 7
		}
	}
	
	var timeLabelArragament : TimeLabelView.Arragement {
		switch self {
		case .origin,.destination,.footTop,.footBottom:
			return .bottom
		case .stopover,.footMiddle,.transfer:
			return .right
		}
	}
	
	var timeLabelSize : ChewTextSize {
		switch self {
		case .stopover:
			return .medium
		default:
			return .big
		}
	}
	
	var timeLabelHeight : Double {
		switch self {
		case .destination,.origin,.footBottom,.footTop:
			return 25
		case .transfer,.footMiddle,.stopover:
			return 15
		}
	}
	
	var viewHeight : Double {
		switch self {
		case .destination:
			return 50
		case .origin:
			return 110
		case .stopover:
			return 35
		case .transfer,.footMiddle:
			return 60
		case .footTop:
			return 70
		case .footBottom:
			return 70
		}
	}
}

enum StopOverCancellationType : Equatable {
	case notCancelled
	case exitOnly
	case entryOnly
	case fullyCancelled
}

struct StopWithTimeDTO : ChewDTO, Identifiable {
	let id = UUID()
	let stop				: StopDTO?
	let departure,
		plannedDeparture	: String?
	let arrival,
		plannedArrival		: String?
	let departureDelay,
		arrivalDelay		: Int?
	let reachable			: Bool?
	let arrivalPlatform,
		plannedArrivalPlatform		: String?
	let departurePlatform,
		plannedDeparturePlatform	: String?
	let remarks						: [Remark]?
	let cancelled : 			Bool?
	
	
	private enum CodingKeys : String, CodingKey {
		case cancelled
		case stop
		case departure
		case plannedDeparture
		case arrival
		case plannedArrival
		case departureDelay
		case arrivalDelay
		case reachable
		case arrivalPlatform
		case plannedArrivalPlatform
		case departurePlatform
		case plannedDeparturePlatform
		case remarks
	}
}

struct StopTripsDTO : ChewDTO {
	let departures : [StopTripDTO]?
	let arrivals : [StopTripDTO]?
}

struct StopTripDTO : ChewDTO, Identifiable {
	let id = UUID()
	let stop : StopDTO?
	let origin : StopDTO?
	let destination : StopDTO?
	let line : LineDTO?
	let remarks : [Remark]?
	let when: String?
	let plannedWhen: String?
	let delay : Int?
	let tripId : String?
	let direction: String?
	let currentLocation: LocationCoordinatesDTO?
	let platform,
		plannedPlatform: String?
	
	private enum CodingKeys : String, CodingKey {
		case stop
		case origin
		case destination
		case line
		case remarks
		case when
		case plannedWhen
		case delay
		case tripId
		case direction
		case currentLocation
		case platform
		case plannedPlatform
	}
}



struct PriceDTO : ChewDTO {
	let amount		: Double?
	let currency	: String?
	let hint		: String?
}

struct JourneyWrapper : ChewDTO {
	let journey : JourneyDTO
	let realtimeDataUpdatedAt: Int64?
}
struct JourneyDTO : ChewDTO,Identifiable {
	let id = UUID()
	let type : String?
	let legs : [LegDTO]
	let refreshToken : String?
	let remarks : [Remark]?
	let price : PriceDTO?
	private enum CodingKeys : String, CodingKey {
		case type
		case legs
		case refreshToken
		case remarks
		case price
	}
}

struct JourneyListDTO : ChewDTO {
	let earlierRef: String?
	let laterRef: String?
	let journeys : [JourneyDTO]?
	let realtimeDataUpdatedAt: Int64?
}

enum LocationType : Int16, Hashable, Codable {
	case pointOfInterest
	case location
	case stop
	case station
	
	var SFSIcon : String {
		switch self {
		case .station:
			return "tram.fill.tunnel"
		case .stop:
			return "bus.fill"
		case .pointOfInterest:
			return ChooSFSymbols.building2CropCircle.rawValue
		case .location:
			return ChooSFSymbols.building2CropCircle.fill.rawValue
		}
	}
}

struct StationDTO : ChewDTO,Identifiable {
	let type	: String?
	let id		: String?
	let name	: String?
	let location	: LocationCoordinatesDTO?
	let latitude	: Double?
	let longitude	: Double?
	let products	: Products?
	
	private enum CodingKeys : String, CodingKey {
		case type
		case id
		case name
		case location
		case products
		case latitude
		case longitude
	}
}

struct StopDTO : ChewDTO, Identifiable {
	let type	: String?
	let id		: String?
	let name	: String?
	let address		: String?
	let location	: LocationCoordinatesDTO?
	let latitude	: Double?
	let longitude	: Double?
	let poi			: Bool?
	let products	: Products?
	let distance  	: Int?
	let station		: StationDTO?
	
	private enum CodingKeys : String, CodingKey {
		case type
		case id
		case name
		case address
		case location
		case products
		case latitude
		case longitude
		case poi
		case distance
		case station
	}
}

extension StopDTO {
	init(name : String, products : Products?) {
		self.name = name
		self.type	= nil
		self.id		= nil
		self.address		= nil
		self.location	= nil
		self.latitude	= nil
		self.longitude	= nil
		self.poi			= nil
		self.products	= products
		self.distance = nil
		self.station = nil
	}
}

extension StopDTO {
	func stop() -> Stop? {
		guard let typeDTO = type  else { return nil }
		
		let type : LocationType = {
			switch typeDTO {
			case "stop":
				return .stop
			case "station":
				return .station
			case "location":
				switch poi {
				case true :
					return .pointOfInterest
				default:
					return .location
				}
			default:
				return .location
			}
		}()
		let productsModified : Products? = {
			if station != nil {
				return Products(
					nationalExpress: false,
					national: false,
					regionalExpress: false,
					regional: false,
					suburban: false,
					bus: self.products?.bus,
					ferry: self.products?.ferry,
					subway: self.products?.subway,
					tram: self.products?.tram,
					taxi: self.products?.taxi
				)
			}
			return self.products
		}()
		return Stop(
			coordinates: Coordinate(
				latitude: latitude ?? location?.latitude ?? 0 ,
				longitude: longitude ?? location?.longitude ?? 0
			),
			type: type,
			stopDTO: StopDTO(
				type: self.type,
				id: self.id,
				name: self.name,
				address: self.address,
				location: self.location,
				latitude: self.latitude,
				longitude: self.longitude,
				poi: self.poi,
				products: productsModified,
				distance: self.distance,
				station: self.station
			)
		)
	}
}


// /departures

struct Departure : Codable,Equatable {
	let tripId				: String?
	let stop				: StopDTO?
	let when				: String?
	let plannedWhen			: String?
	let prognosedWhen		: String?
	let delay				: Int?
	let platform			: String?
	let plannedPlatform		: String?
	let prognosedPlatform	: String?
	let prognosisType		: String?
	let direction			: String?
	let provenance			: String?
	let line				: LineDTO?
	let remarks				: [Remark]?
	let origin				: String?
	let destination			: StopDTO?
	let cancelled			: Bool?
}


// MARK: - Location
struct LocationCoordinatesDTO : Codable,Hashable {
	let type		: String?
	let id			: String?
	let latitude	: Double?
	let longitude	: Double?
}

// MARK: - Products
struct Products : Codable, Equatable,Hashable {
	let nationalExpress		: Bool?
	let national			: Bool?
	let regionalExpress		: Bool?
	let regional			: Bool?
	let suburban			: Bool?
	let bus					: Bool?
	let ferry				: Bool?
	let subway				: Bool?
	let tram				: Bool?
	let taxi				: Bool?
	init(
		nationalExpress: Bool? = false,
		national: Bool? = false,
		regionalExpress: Bool? = false,
		regional: Bool? = false,
		suburban: Bool? = false,
		bus: Bool? = false,
		ferry: Bool? = false,
		subway: Bool? = false,
		tram: Bool? = false,
		taxi: Bool? = false
	) {
		self.nationalExpress = nationalExpress
		self.national = national
		self.regionalExpress = regionalExpress
		self.regional = regional
		self.suburban = suburban
		self.bus = bus
		self.ferry = ferry
		self.subway = subway
		self.tram = tram
		self.taxi = taxi
	}
}

extension Products {
	var lineType : LineType? {
		if national == true {
			return .national
		}
		if nationalExpress == true {
			return .nationalExpress
		}
		if regional == true {
			return .regional
		}
		if regionalExpress == true {
			return .regionalExpress
		}
		if suburban == true {
			return .suburban
		}
		if subway == true {
			return .subway
		}
		if tram == true {
			return .tram
		}
		if bus == true {
			return .bus
		}
		if ferry == true {
			return .ferry
		}
		if taxi == true {
			return .taxi
		}
		return nil
	}
}

// MARK: - Line
struct LineDTO : Codable,Hashable {
	let type			: String?
	let id				: String?
	let fahrtNr			: String?
	let name			: String?
	let linePublic		: Bool?
	let adminCode		: String?
	let productName		: String?
	let mode			: String?
	let product			: String?
}

// MARK: - Remark
struct Remark : Codable,Hashable {
	let type	: String?
	let code	: String?
	let text	: String?
	let summary : String?
}

extension Remark {
	func viewData() -> RemarkViewData? {
		if let type = RemarkViewData.RemarkType(rawValue: type ?? ""),
		   let text = text,
		let summary = summary {
			return RemarkViewData(
				type: type,
				summary: summary,
				text: text
			)
		}
		return nil
	}
}

struct Station : Codable,Equatable {
	let EVA_NR			: Int?
	let DS100			: String?
	let IFOPT			: String?
	let NAME			: String?
	let Verkehr			: String?
	let Laenge			: Double?
	let Breite			: Double?
	let Betreiber_Nr	: Int?
	let Status			: String?
}


struct HafasErrorDTO : Codable, Equatable {
	let message : String? 				// "H9220: journeys search: no stations found close to the address"
	let isHafasError: Bool?
	let code : String? 				// "NOT_FOUND"
	let isCausedByServer : Bool?
	let hafasCode : String? 			// "H9220"
	let hafasMessage : String? 		// "HAFAS Kernel: Nearby to the given address stations could not be found."
	let hafasDescription : String? 	// "No suitable stops found near the address entered"
}
