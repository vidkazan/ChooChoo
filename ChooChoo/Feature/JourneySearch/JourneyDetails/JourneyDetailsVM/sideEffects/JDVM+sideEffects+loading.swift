
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

	static func whenLoadingIfNeeded() -> Feedback<State, Event> {
		Feedback {(state: State) -> AnyPublisher<Event, Never> in
			switch state.status {
			case let .loadingIfNeeded(id,token,status):
				if Date.now.timeIntervalSince1970 - state.data.viewData.updatedAt < status.updateIntervalInMinutes * 60 {
					return Just(Event.didCancelToLoadData).eraseToAnyPublisher()
				}
				return Just(Event.didTapReloadButton(id: id,ref: token)).eraseToAnyPublisher()
			default:
				return Empty().eraseToAnyPublisher()
			}
		}
	}
	
	
	static func whenLoadingJourneyByRefreshToken() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			var token : String!
			var followID : Int64
			
			switch state.status {
			case let .loading(id, ref):
				token = ref
				followID = id
			default:
				return Empty().eraseToAnyPublisher()
			}
			
			guard let token = token else {
				return Just(Event.didFailedToLoadJourneyData(error: DataError.nilValue(type: "journeyRef"))).eraseToAnyPublisher()
			}

			return Self.fetchJourneyByRefreshToken(
				ref: token,
				mode: .withoutPolylines
			)
				.mapError{ $0 }
				.asyncFlatMap{ data in
					
					let res = await data.journey.journeyViewDataAsync(
						depStop: state.data.depStop,
						arrStop: state.data.arrStop,
						realtimeDataUpdatedAt: Date.now.timeIntervalSince1970,
						settings: state.data.viewData.settings
					)
					
					guard let res = res else {
						return Event.didFailedToLoadJourneyData(error: DataError.nilValue(type: "viewData"))
					}
					
					if Model.shared.journeyFollowVM.state.journeys.contains(where: {$0.id == followID}) == true {
						Model.shared.journeyFollowVM.send(event: .didRequestUpdateJourney(res, followID))
					}
										
					return Event.didLoadJourneyData(data: res)
				}
				.catch {
					error in Just(.didFailedToLoadJourneyData(error: error as! (any ChewError)))
				}
				.eraseToAnyPublisher()
		}
	}
}
