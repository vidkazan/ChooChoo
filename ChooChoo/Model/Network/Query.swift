//
//  Query.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation


extension URLQueryItem {
	func departure() -> Self {
		var item  = self
		item.name = "from." + item.name
		return item
	}
	func arrival() -> Self {
		var item  = self
		item.name = "to." + item.name
		return item
	}
}

enum Query {
	case transferTime(transferTime: Int)
	case location(location : String?)
	case when(time : Date?)
	case direction(dir : String)
	case duration(minutes : Int)
	case results(max: Int)
	case linesOfStops(showStopLines : Bool)
	case remarks(showRemarks: Bool)
	case language(language : String)
	case pretty(pretyIntend: Bool)
	case polylines(_ isShowing : Bool)
	case transfersCount(_ count : Int)
	
	case nationalExpress(iceTrains: Bool)
	case national(icTrains: Bool)
	case regionalExpress(reTrains: Bool)
	case regional(rbTrains: Bool)
	case suburban(sBahn: Bool)
	case bus(bus: Bool)
	case ferry(ferry: Bool)
	case subway(uBahn: Bool)
	case tram(tram: Bool)
	case taxi(taxi : Bool)
	
	case latitude(latitude : String)
	case longitude(longitude : String)
    case reiseloesungOrteNearbylat(latitude : String)
    case reiseloesungOrteNearbylong(longitude : String)
    
    
    
	case address(addr: String)
	case poiId(poiId: String)
	case poiName(poiName: String)
	
	case departureStopId(departureStopId : String)
	case arrivalStopId(arrivalStopId : String)
	case departureTime(departureTime : Date)
	case arrivalTime(arrivalTime : Date)
	case earlierThan(earlierRef : String)
	case laterThan(laterRef : String)
	
	case showAddresses(showAddresses : Bool)
	case showPointsOfInterests(showPointsOfInterests : Bool)
	case stopovers(isShowing: Bool)
	
	case accessibility(JourneySettings.Accessiblity)
	case bike(Bool)
	case startWithWalking(Bool)
	case walkingSpeed(JourneySettings.WalkingSpeed)
	case linesOfStops(show : Bool)
    
    case reiseloesungOrteNearbyRadius(radius : Int)
    case reiseloesungOrteNearbyMaxNo(numberOfResults : Int)
    case reiseloesungOrteTyp(type : String)
    case reiseloesungOrteLimit(limit : Int)
    case reiseloesungOrteSuchbegriff(str : String)
    
    case reiseloesungAbfahrtenDatum(String)
    case reiseloesungAbfahrtenZeit(String)
    case reiseloesungAbfahrtenOrtExtId(Int)
    case reiseloesungAbfahrtenOrtId(String)
    case reiseloesungAbfahrtenMitVias(Bool)
    case reiseloesungAbfahrtenMaxVias(max : Int)
    case reiseloesungAbfahrtenVerkehrsmittel(transport : StopResponseIntlBahnDe.EndpointProducts)
    
	func queryItem() -> URLQueryItem {
		switch self {
		case .walkingSpeed(let speed):
			return URLQueryItem(
				name: "walkingSpeed",
				value: speed.string)
		case .startWithWalking(let val):
			return URLQueryItem(
				name: "startWithWalking",
				value: String(val))
		case .bike(let bike):
			return URLQueryItem(
				name: "bike",
				value: String(bike))
		case .accessibility(let acc):
			return URLQueryItem(
				name: "accessibility",
				value: acc.string)
		case .location(let location):
			return URLQueryItem(
				name: "query",
				value: location)
		case .when(let time):
			var res = Date.now
			if let time = time {
				res = time
			}
			return URLQueryItem(name: "when", value: String(res.timeIntervalSince1970))
		case .direction(let dir):
			return URLQueryItem(
				name: "direction",
				value: dir)
		case .duration(let minutes):
			return URLQueryItem(
				name: "duration",
				value: String(minutes))
		case .results(let max):
			return URLQueryItem(
				name: "results",
				value: String(max))
		case .linesOfStops(let showStopLines):
			return URLQueryItem(
				name: "linesOfStops",
				value: String(showStopLines))
		case .remarks(let showRemarks):
			return URLQueryItem(
				name: "remarks",
				value: String(showRemarks))
		case .language(let language):
			return URLQueryItem(
				name: "language",
				value: language)
		case .nationalExpress(let iceTrains):
			return URLQueryItem(
				name: "nationalExpress",
				value: String(iceTrains))
		case .national(let icTrains):
			return URLQueryItem(
				name: "national",
				value: String(icTrains))
		case .regionalExpress(let reTrains):
			return URLQueryItem(
				name: "regionalExpress",
				value: String(reTrains))
		case .regional(let rbTrains):
			return URLQueryItem(
				name: "regional",
				value: String(rbTrains))
		case .suburban(let sBahn):
			return URLQueryItem(
				name: "suburban",
				value: String(sBahn))
		case .bus(let bus):
			return URLQueryItem(
				name: "bus",
				value: String(bus))
		case .ferry(let ferry):
			return URLQueryItem(
				name: "ferry",
				value: String(ferry))
		case .subway(let uBahn):
			return URLQueryItem(
				name: "subway",
				value: String(uBahn))
		case .tram(let tram):
			return URLQueryItem(
				name: "tram",
				value: String(tram))
		case .taxi(let taxi):
			return URLQueryItem(
				name: "taxi",
				value: String(taxi))
		case .pretty(let prettyIntend):
			return URLQueryItem(
				name: "pretty",
				value: String(prettyIntend))
		case .departureStopId(let departureStopId):
			return URLQueryItem(
				name: "from",
				value: departureStopId)
		case .arrivalStopId(let arrivalStopId):
			return URLQueryItem(
				name: "to",
				value: arrivalStopId)
		case .departureTime(let departureTime):
			return URLQueryItem(
				name: "departure",
				value: ISO8601DateFormatter().string(from: departureTime))
		case .arrivalTime(let arrivalTime):
			return URLQueryItem(
				name: "arrival",
				value: ISO8601DateFormatter().string(from: arrivalTime))
		case .transferTime(let transferTime):
			return URLQueryItem(
				name: "transferTime",
				value: String(transferTime))
		case .earlierThan(earlierRef: let earlierRef):
			return URLQueryItem(
				name: "earlierThan",
				value: earlierRef)
		case .laterThan(laterRef: let laterRef):
			return URLQueryItem(
				name: "laterThan",
				value: laterRef)
		case .showAddresses(showAddresses: let showAddresses):
			return URLQueryItem(
				name: "addresses",
				value: String(showAddresses))
		case .showPointsOfInterests(showPointsOfInterests: let showPointsOfInterests):
			return URLQueryItem(
				name: "poi",
				value: String(showPointsOfInterests))
		case .latitude(latitude: let latitude):
			return URLQueryItem(
				name: "latitude",
				value: String(latitude))
		case .longitude(longitude: let longitude):
			return URLQueryItem(
				name: "longitude",
				value: String(longitude))
        case .reiseloesungOrteNearbyRadius(let radius):
            return URLQueryItem(
                name: "radius",
                value: String(radius))
        case .reiseloesungOrteNearbyMaxNo(let numberOfResults):
            return URLQueryItem(
                name: "maxNo",
                value: String(numberOfResults))
        case .reiseloesungOrteNearbylat(latitude: let latitude):
            return URLQueryItem(
                name: "lat",
                value: String(latitude))
        case .reiseloesungOrteNearbylong(longitude: let longitude):
            return URLQueryItem(
                name: "long",
                value: String(longitude))
        case .reiseloesungOrteTyp(let type):
                return URLQueryItem(
                    name: "typ",
                    value: type)
        case .reiseloesungOrteLimit(let limit):
                return URLQueryItem(
                    name: "limit",
                    value: String(limit))
        case .reiseloesungOrteSuchbegriff(let str):
                return URLQueryItem(
                    name: "suchbegriff",
                    value: str)
		case .address(addr: let addr):
			return URLQueryItem(
				name: "address",
				value: String(addr))
			
		case .poiId(poiId: let poiId):
			return URLQueryItem(
				name: "id",
				value: String(poiId))
		
		case .stopovers(isShowing: let isShowing):
			return URLQueryItem(
				name: "stopovers",
				value: String(isShowing))
		case .polylines(let show):
			return URLQueryItem(
				name: "polylines",
				value: String(show))
		case .transfersCount(let count):
			return URLQueryItem(
				name: "transfers",
				value: String(count))
		case .poiName(poiName: let poiName):
			return URLQueryItem(
				name: "name",
				value: poiName)
            case .reiseloesungAbfahrtenDatum(let datum):
                return URLQueryItem(
                    name: "datum",
                    value: datum
                )
            case .reiseloesungAbfahrtenZeit(let zeit):
                return URLQueryItem(
                    name: "zeit",
                    value: zeit
                )
            case .reiseloesungAbfahrtenOrtExtId(let id):
                return URLQueryItem(
                    name: "ortExtId",
                    value: String(id)
                )
            case .reiseloesungAbfahrtenOrtId(let id):
                return URLQueryItem(
                    name: "ortId",
                    value: id
                )
            case .reiseloesungAbfahrtenMitVias(let bool):
                return URLQueryItem(
                    name: "mitVias",
                    value: String(bool)
                )
            case .reiseloesungAbfahrtenMaxVias(max: let max):
                return URLQueryItem(
                    name: "maxVias",
                    value: String(max)
                )
            case .reiseloesungAbfahrtenVerkehrsmittel(transport: let transport):
                return URLQueryItem(
                    name: "verkehrsmittel[]",
                    value: transport.rawValue
                )
        }
	}
	static func queryItems(methods : [Query]) -> [URLQueryItem] {
		return methods.map {
			$0.queryItem()
		}
	}
}

