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

class ChooNetworking  {
	let client : ChooClient
	
	init(client : ChooClient = ApiClient()) {
		self.client = client
	}
}

extension ChooNetworking {
	func fetch<T: Decodable>(
		_ t : T.Type,
		query : [URLQueryItem],
		type : Requests
	) -> AnyPublisher<T, ApiError> {
		guard let url = ChooNetworking.generateUrl(
			query: query,
			type: type,
			host: Constants.apiData.urlBase
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
