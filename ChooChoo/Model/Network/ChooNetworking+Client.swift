//
//  ApiService.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import Combine
import CoreLocation
import OSLog
import ChooNetworking

extension ChooNetworking {
	class ApiClient : ChooClient {
		func execute<T:Decodable,V:ChooRequest>(_ t : T.Type,request: URLRequest, type : V) -> AnyPublisher<T,ChooNetworking.ApiError> {
			return URLSession.shared
				.dataTaskPublisher(for: request)
				.tryMap { data, response -> T in
					guard let response = response as? HTTPURLResponse else {
						throw ApiError.cannotDecodeRawData
					}
					switch response.statusCode {
					case 400...599:
						if let data = try? JSONDecoder().decode(HafasErrorDTO.self, from: data) {
							throw ApiError.hafasError(data)
						}
						throw ApiError.badServerResponse(code: response.statusCode)
					default:
						break
					}
					let value = try JSONDecoder().decode(T.self, from: data)
					let url = request.url?.path ?? ""
					Logger.networking.trace("done: \(type.description)  \(url)")
					return value
				}
				.receive(on: DispatchQueue.main)
				.mapError{ error -> ApiError in
					let url = request.url?.path ?? ""
					Logger.networking.error("\(type.description) \(url) \(error)")
					switch error {
					case let error as ApiError:
						return error
					default:
						return .generic(description: error.localizedDescription)
					}
				}
				.eraseToAnyPublisher()
		}
	}
}

extension ChooNetworking {
	class MockClient : ChooClient {
		var inputRequest: URLRequest?
		var executeCalled = false
		var requestType : (any ChooRequest)?
		
		func execute<T:Decodable,V:ChooRequest>(_ t : T.Type,request: URLRequest, type : V) -> AnyPublisher<T,ChooNetworking.ApiError> {
			executeCalled = true
			inputRequest = request
			requestType = type
			return Empty().eraseToAnyPublisher()
		}
	}
}
