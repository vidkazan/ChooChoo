//
//  SearchJourneyVM+feedback.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//

import Foundation
import Combine
import OSLog

extension JourneyListViewModel {
	static func whenLoadingJourneyRef() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingRef(let type) = state.status else { return Empty().eraseToAnyPublisher() }
			switch type {
			case .initial:
				return Just(Event.onReloadJourneyList).eraseToAnyPublisher()
				
			case .earlierRef:
				guard let ref = state.data.earlierRef else {
					Logger.fetchJourneyRef.error("earlierRef is nil")
					return Just(Event.didFailToLoadEarlierRef(DataError.nilValue(type: "earlierRef"))).eraseToAnyPublisher()
				}
				return Self.fetchEarlierOrLaterRef(
					dep: state.data.stops.departure,
					arr: state.data.stops.arrival,
					ref: ref,
					type: type,
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
								arrStop: state.data.stops.arrival),
							.earlierRef
						)
					}
					.catch { error in
						Just(Event.didFailToLoadEarlierRef(error as? ChooNetworking.ApiError ?? .generic(description: error.localizedDescription)))
					}
					.eraseToAnyPublisher()
				
				
			case .laterRef:
				guard let ref = state.data.laterRef else {
					Logger.fetchJourneyRef.error("laterRef is nil")
					return Just(Event.didFailToLoadEarlierRef(DataError.nilValue(type: "laterRef"))).eraseToAnyPublisher()
				}
				return Self.fetchEarlierOrLaterRef(
					dep: state.data.stops.departure,
					arr: state.data.stops.arrival,
					ref: ref,
					type: type,
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
						return Event.onNewJourneyListData(JourneyListViewData(
							journeysViewData: res,
							data: data,
							depStop: state.data.stops.departure,
							arrStop: state.data.stops.arrival),.laterRef
						)
					}
					.catch { error in
						Just(Event.didFailToLoadLaterRef(error as? ChooNetworking.ApiError ?? .generic(description: error.localizedDescription)))
					}
					.eraseToAnyPublisher()
			}
		}
	}
	
	static func fetchEarlierOrLaterRef(dep : Stop,arr : Stop,ref : String, type : JourneyUpdateType,settings : JourneySettings) -> AnyPublisher<JourneyListDTO,ChooNetworking.ApiError> {
		var query = addJourneyListStopsQuery(dep: dep, arr: arr)
		query += Query.queryItems(methods: [
			type == .earlierRef ? Query.earlierThan(earlierRef: ref) : Query.laterThan(laterRef: ref),
			Query.remarks(showRemarks: true),
			Query.results(max: 3),
			Query.stopovers(isShowing: true)
		])
		query += self.addJourneyListTransportModes(settings: settings)
		return ChooNetworking().fetch(JourneyListDTO.self,query: query, type: ChooNetworking.Requests.journeys)
	}
}

