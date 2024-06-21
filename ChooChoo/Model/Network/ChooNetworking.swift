//
//  ApiService.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import Combine
import CoreLocation

class ChooNetworking  {
	let client : ChewClient
	
	init(client : ChewClient = ApiClient()) {
		self.client = client
	}
}

extension ChooNetworking {
	enum Requests : Equatable {
		case journeys
		case journeyByRefreshToken(ref : String)
		case locations
		case locationsNearby(coords : CLLocationCoordinate2D)
		case stopDepartures(stopId : String)
		case stopArrivals(stopId : String)
		case trips(tripId : String)
		case generic(path : String)
		
		var description : String {
			switch self {
			case .locationsNearby:
				return "locationsNearby"
			case .locations:
				return "locations"
			case .generic:
				return "generic"
			case .journeys:
				return "journeys"
			case .journeyByRefreshToken:
				return "journeyByRefreshToken"
			case .trips:
				return "trips"
			case .stopDepartures:
				return "stopDepartures"
			case .stopArrivals:
				return "stopArrivals"
			}
		}
		
		var method : String {
			switch self {
			default:
				return "GET"
			}
		}
		
		var headers : [(value : String, key : String)] {
			switch self {
			default:
				return []
			}
		}
		
		var urlString : String {
			switch self {
			case .locationsNearby:
				return Constants.apiData.urlPathLocationsNearby
			case .journeys:
				return Constants.apiData.urlPathJourneyList
			case .locations:
				return Constants.apiData.urlPathLocations
			case .generic(let path):
				return path
			case .journeyByRefreshToken(let ref):
				return Constants.apiData.urlPathJourneyList + "/" + ref
			case .trips(tripId: let tripId):
				return Constants.apiData.urlPathTrip + "/" + tripId
			case .stopDepartures(let stopId):
				return Constants.apiData.urlPathStops + stopId + "/departures"
			case .stopArrivals(let stopId):
				return Constants.apiData.urlPathStops + stopId + "/arrivals"
			}
		}
		
		func getRequest(urlEndPoint : URL) -> URLRequest {
			switch self {
			default:
				var req = URLRequest(url : urlEndPoint)
				req.httpMethod = self.method
				for header in self.headers {
					req.addValue(header.value, forHTTPHeaderField: header.key)
				}
				return req
			}
		}
	}

	static func generateUrl(query : [URLQueryItem], type : Requests, host : String) -> URL? {
		let url : URL? = {
			switch type {
			case .generic(let path):
				return URL(string: path)
			default:
				var components = URLComponents()
				components.path = type.urlString
				components.host = host
				components.scheme = "https"
				components.queryItems = query
				return components.url
			}
		}()
		return url
	}
}

