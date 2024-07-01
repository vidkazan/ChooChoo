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
import ChooNetworking

extension JourneyDetailsViewModel {
	enum FetchJourneyByRefreshTokenMode {
		case full
		case withoutPolylines
	}
	
	static func fetchJourneyByRefreshToken(ref : String, mode : FetchJourneyByRefreshTokenMode = .full) -> (AnyPublisher<JourneyWrapper,ChooApiError>) {
		let queryMethods = {
			switch mode {
			case .full:
				return [
					Query.stopovers(isShowing: true),
					Query.polylines(true),
				]
			case .withoutPolylines:
				return [
					Query.stopovers(isShowing: true)
				]
			}
		}()
		return ChooNetworking().fetch(
			JourneyWrapper.self,
			query: Query.queryItems(
				methods: queryMethods
			),
			type: ChooRequest.journeyByRefreshToken(ref: ref)
		)
		.eraseToAnyPublisher()
	}
	
	static func fetchTrip(tripId : String) -> AnyPublisher<LegDTO,ChooApiError> {
		return ChooNetworking().fetch(
			TripDTO.self,
			query: [],
			type: ChooRequest.trips(tripId: tripId)
		)
		.map { $0.trip }
		.eraseToAnyPublisher()
	}
}
