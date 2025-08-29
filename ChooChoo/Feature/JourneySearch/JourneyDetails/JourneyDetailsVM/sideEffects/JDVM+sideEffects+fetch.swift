//
//  JourneyDetailsVM+sideEffect.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Foundation
import Combine
import CoreLocation
import MapKit

extension JourneyDetailsViewModel {
	enum FetchJourneyByRefreshTokenMode {
		case full
		case withoutPolylines
	}
	
    static func fetchJourneyByRefreshToken(
        ref : String,
        mode : FetchJourneyByRefreshTokenMode = .withoutPolylines,
        settings : JourneySettings
    ) -> (AnyPublisher<JourneyWrapper,ApiError>) {
//		let queryMethods = {
//			switch mode {
//			case .full:
//				return [
//					Query.stopovers(isShowing: true),
//					Query.polylines(true),
//				]
//			case .withoutPolylines:
//				return [
//					Query.stopovers(isShowing: true)
//				]
//			}
//		}()
//		return ApiService().fetch(
//			JourneyWrapper.self,
//			query: Query.queryItems(
//				methods: queryMethods
//			),
//			type: ApiService.Requests.journeyByRefreshToken(ref: ref)
//		)
        let request = JourneyUpdateRequestIntBahnDe(
            settings: settings,
            journeyRef: ref
        )
        return RequestFabric().fetch(
            JourneyResponseIntBahnDe.self,
            query: [],
            type: RequestFabric.Requests.journeyByRefreshToken(request)
        )
        .tryMap {
            guard let update = $0.verbindungen.first else {
                throw ApiError.connectionNotFound
            }
            return JourneyWrapper(
                journey: update.journeyDTO(),
                realtimeDataUpdatedAt: nil
            )
        }
        .mapError{
            ApiError.generic(description: $0.localizedDescription)
        }
		.eraseToAnyPublisher()
	}
	
	static func fetchTrip(tripId : String) -> AnyPublisher<LegDTO,ApiError> {
		return RequestFabric().fetch(
			TripDTO.self,
			query: [],
			type: RequestFabric.Requests.trips(tripId: tripId)
		)
		.map { $0.trip }
		.eraseToAnyPublisher()
	}
}
