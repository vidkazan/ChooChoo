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
                        requset: JourneyRequestIntBahnDe(
                            settings: state.data.settings,
                            dep: state.data.stops.departure,
                            arr: state.data.stops.arrival,
                            time: state.data.date.date.date,
                            mode: state.data.date.mode,
                            pagingReference: nil
                        ),
                        type: .earlierRef(ref)
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
                            .earlierRef(data.earlierRef)
						)
					}
					.catch { error in
						Just(Event.didFailToLoadEarlierRef(error as? ApiError ?? .generic(description: error.localizedDescription)))
					}
					.eraseToAnyPublisher()
				
				
			case .laterRef:
				guard let ref = state.data.laterRef else {
					Logger.fetchJourneyRef.error("laterRef is nil")
					return Just(Event.didFailToLoadEarlierRef(DataError.nilValue(type: "laterRef"))).eraseToAnyPublisher()
				}
                    return Self.fetchEarlierOrLaterRef(
                        requset: JourneyRequestIntBahnDe(
                            settings: state.data.settings,
                            dep: state.data.stops.departure,
                            arr: state.data.stops.arrival,
                            time: state.data.date.date.date,
                            mode: state.data.date.mode,
                            pagingReference: nil
                        ),
                        type: .laterRef(ref)
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
                            .laterRef(data.laterRef)
						)
					}
					.catch { error in
						Just(Event.didFailToLoadLaterRef(error as? ApiError ?? .generic(description: error.localizedDescription)))
					}
					.eraseToAnyPublisher()
			}
		}
	}
	
    static func fetchEarlierOrLaterRef(requset : JourneyRequestIntBahnDe, type : JourneyUpdateType) -> AnyPublisher<JourneyListDTO,ApiError> {
        //		var query = addJourneyListStopsQuery(dep: dep, arr: arr)
        //		query += Query.queryItems(methods: [
        //			type == .earlierRef ? Query.earlierThan(earlierRef: ref) : Query.laterThan(laterRef: ref),
        //			Query.remarks(showRemarks: true),
        //			Query.results(max: 3),
        //			Query.stopovers(isShowing: true)
        //		])
        let requset = JourneyRequestIntBahnDe(
            request: requset,
            pagingReference: type
        )
        //		query += self.addJourneyListTransportModes(settings: settings)
        return ApiService()
            .fetch(
                JourneyResponseIntBahnDe.self,
                query: [],
                type: ApiService.Requests.journeys(requset)
            )
            .map { $0.journeyDTO() }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}

