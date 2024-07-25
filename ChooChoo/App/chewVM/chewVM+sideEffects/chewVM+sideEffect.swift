//
//  +sideEffect.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Combine
import Foundation
import SwiftUI

extension ChewViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	
	static func whenIdleCheckForSufficientDataForJourneyRequest() -> Feedback<State, Event> {
		Feedback {  (state: State) -> AnyPublisher<Event, Never> in
			guard case .checkingSearchData = state.status else { return Empty().eraseToAnyPublisher() }
			guard let dep = state.data.depStop.stop, let arr = state.data.arrStop.stop else {
				return Just(Event.onNotEnoughSearchData)
					.eraseToAnyPublisher()
			}
			
			if case .location = state.data.depStop {
				Model.shared.recentSearchesVM.send(event: .didTapEdit(
						action: .adding,
						search: RecentSearchesViewModel.RecentSearch(
							depStop: dep,
							arrStop: arr,
							searchTS: Date.now.timeIntervalSince1970
						)
					)
				)
			}
			
			return Just(Event.onJourneyDataUpdated(
				DepartureArrivalPairStop(
					departure: dep,
					arrival: arr
				)
			))
			.eraseToAnyPublisher()
		}
	}
	
	static func whenEditingStops() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			if case let .editingStop(type) = state.status {
				Model.shared.searchStopsVM.send(event: .didChangeFieldFocus(type: type))
			}
			return Empty().eraseToAnyPublisher()
		}
	}
}

