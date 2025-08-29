//
//  ApiService.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import Combine
import CoreLocation

struct RequestFabric  {
    
    
    enum Requests : Equatable {
		case journeys(JourneyRequestIntBahnDe)
		case journeyByRefreshToken(JourneyUpdateRequestIntBahnDe)
		case locations
		case locationsNearby
		case stopDepartures
		case stopArrivals
		case trips(tripId : String)
		case generic(path : String)
        case addresslookup
		
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
            case .addresslookup:
                return "addresslookup"
			}
		}
		
		var method : String {
			switch self {
                case .journeys,.journeyByRefreshToken:
                return "POST"
			default:
				return "GET"
			}
		}
		
		var headers : [(value : String, key : String)] {
			switch self {
                case .journeys,.journeyByRefreshToken:
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
			case .journeyByRefreshToken:
                return Constants.ApiDataIntBahnDe.urlPathJourneyUpdate
			case .trips(tripId: let tripId):
				return Constants.ApiDataIntBahnDe.urlPathTrip
			case .stopDepartures:
                    return Constants.ApiDataIntBahnDe.urlPathDepartures
			case .stopArrivals:
                    return Constants.ApiDataIntBahnDe.urlPathArrivals
                case .addresslookup:
                    return Constants.ApiDataIntBahnDe.urlPathTripAddresslookup
			}
		}
		
        var body : Data? {
            switch self {
                case .journeys(let journeyRequestIntBahnDe):
                    let data = try? JSONEncoder().encode(journeyRequestIntBahnDe)
//                    print(">>>",String.init(data: data ?? Data(), encoding: .utf8))
                    return data
                case .journeyByRefreshToken(let request):
                    let data = try? JSONEncoder().encode(request)
//                    print(">>>",String.init(data: data ?? Data(), encoding: .utf8))
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
