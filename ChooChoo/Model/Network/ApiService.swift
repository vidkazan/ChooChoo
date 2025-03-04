//
//  ApiService.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import Combine
import CoreLocation

class ApiService  {
	let client : ChewClient
	
	init(client : ChewClient = ApiClient()) {
		self.client = client
	}
	
    enum Requests : Equatable {
		case journeys(JourneyRequestIntBahnDe)
		case journeyByRefreshToken(ref : String)
		case locations
		case locationsNearby
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
            case .locationsNearby:
                return "GET"
            case .journeys:
                return "POST"
			default:
				return "GET"
			}
		}
		
		var headers : [(value : String, key : String)] {
			switch self {
            case .journeys:
                return [
                    ("application/json","Content-Type")
                ]
			default:
				return []
			}
		}
		
		var urlString : String {
			switch self {
			case .locationsNearby:
				return Constants.ApiDataIntBahnDe.urlPathLocationsNearby
			case .journeys:
				return Constants.ApiDataIntBahnDe.urlPathJourneyList
			case .locations:
				return Constants.ApiDataIntBahnDe.urlPathLocations
			case .generic(let path):
				return path
			case .journeyByRefreshToken(let ref):
				return Constants.ApiDataIntBahnDe.urlPathJourneyList + "/" + ref
			case .trips(tripId: let tripId):
				return Constants.ApiDataIntBahnDe.urlPathTrip + "/" + tripId
			case .stopDepartures(let stopId):
				return Constants.ApiDataIntBahnDe.urlPathStops + stopId + "/departures"
			case .stopArrivals(let stopId):
				return Constants.ApiDataIntBahnDe.urlPathStops + stopId + "/arrivals"
			}
		}
		
        var body : Data? {
            switch self {
                case .journeys(let journeyRequestIntBahnDe):
                    let data = try? JSONEncoder().encode(journeyRequestIntBahnDe)
                    print(">>>",String.init(data: data ?? Data(), encoding: .utf8))
                    return data
                default:
                    return Data()
            }
        }
		func getRequest(urlEndPoint : URL) -> URLRequest {
			switch self {
			default:
				var req = URLRequest(url : urlEndPoint)
                req.httpBody = self.body
				req.httpMethod = self.method
				for header in self.headers {
					req.addValue(header.value, forHTTPHeaderField: header.key)
				}
				return req
			}
		}
	}

	static func generateUrl(query : [URLQueryItem], type : Requests) -> URL? {
		let url : URL? = {
			switch type {
			case .generic(let path):
				return URL(string: path)
			default:
				var components = URLComponents()
				components.path = type.urlString
				components.host = Constants.ApiDataIntBahnDe.urlBase
				components.scheme = "https"
				components.queryItems = query
                return components.url
			}
		}()
		return url
	}
}
