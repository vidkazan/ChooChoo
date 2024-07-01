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

class ChooNetworking : FcodyNetworking {
	func fetch<T: Decodable>(
		_ t : T.Type,
		query : [URLQueryItem],
		type : ChooRequest
	) -> AnyPublisher<T, ChooApiError> {
		fetchInner(t, query: query, type: type)
		.mapError {
			$0.chooApiError()
		}.eraseToAnyPublisher()
	}
}
