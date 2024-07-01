//
//  SearchJourneyVM+feedback.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//

import Foundation
import Combine
import ChooNetworking

extension JourneyListViewModel {
	static func whenLoadingJourneyList() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingJourneyList = state.status else { return Empty().eraseToAnyPublisher() }
			return Self.fetchJourneyList(
				dep: state.data.stops.departure,
				arr: state.data.stops.arrival,
				time: state.data.date.date.date,
				mode: state.data.date.mode,
				settings: state.data.settings
			)
				.mapError{ $0 }
				.asyncFlatMap { data in
					let res = await constructJourneyListViewDataAsync(
						journeysData: data,
						depStop: state.data.stops.departure,
						arrStop: state.data.stops.arrival,
						settings: state.data.settings
					)
					return Event.onNewJourneyListData(
						JourneyListViewData(
							journeysViewData: res,
							data: data,
							depStop: state.data.stops.departure,
							arrStop: state.data.stops.arrival
						),
						JourneyUpdateType.initial
					)
				}
				.catch { error in
					Just(Event.onFailedToLoadJourneyListData( error as? ChooApiError ?? ChooApiError.generic(description: error.localizedDescription))
					)
				}
				.eraseToAnyPublisher()
		}
	}
}

