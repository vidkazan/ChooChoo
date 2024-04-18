//
//  ApiService.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import Combine
import OSLog

protocol ChewClient {
	func execute<T:Decodable>(_ t : T.Type,request: URLRequest, type : ApiService.Requests) -> AnyPublisher<T,ApiError>
}

class ApiClient : ChewClient {
	func execute<T: Decodable>(
		_ t : T.Type,
		request : URLRequest,
		type : ApiService.Requests
	) -> AnyPublisher<T, ApiError> {
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
				Logger.networking.debug("done: \(type.description)  \(url)")
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

extension ApiService {
	func fetch<T: Decodable>(
		_ t : T.Type,
		query : [URLQueryItem],
		type : Requests
	) -> AnyPublisher<T, ApiError> {
		guard let url = ApiService.generateUrl(
			query: query,
			type: type
		) else {
			return Future<T,ApiError> {
				return $0(.failure(.badUrl))
			}.eraseToAnyPublisher()
		}
		
		let request = type.getRequest(urlEndPoint: url)
		return self.client.execute(
			t.self,
			request: request,
			type: type
		)
	}
}

class MockClient : ChewClient {
	
	var inputRequest: URLRequest?
	var executeCalled = false
	var requestType : ApiService.Requests?
	
	func execute<T: Decodable>(
		_ t : T.Type,
		request : URLRequest,
		type : ApiService.Requests
	) -> AnyPublisher<T, ApiError> {
		executeCalled = true
		inputRequest = request
		requestType = type
		return Empty().eraseToAnyPublisher()
	}
}
