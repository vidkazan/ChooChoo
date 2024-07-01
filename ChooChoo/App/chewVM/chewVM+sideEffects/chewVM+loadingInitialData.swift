//
//  +sideEffect.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Combine
import Foundation
import SwiftUI
import OSLog


extension ChewViewModel {
	static func whenLoadingInitialData(coreDataStore : ChooDataStore) -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingInitialData = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			guard coreDataStore.fetchUser() != nil else {
				Logger.loadingsInitialData.info("\(#function): user is nil: loading default data")
				return Just(Event.didLoadInitialData(JourneySettings()))
					.eraseToAnyPublisher()
			}

			Task {
				if let appSettings = coreDataStore.fetchAppSettings() {
					Model.shared.appSettingsVM.send(
						event: .didRequestToLoadInitialData(settings: appSettings)
					)
				} else {
					Logger.loadingsInitialData.info("\(#function): appSettings is nil")
				}
				if let stops = coreDataStore.fetchLocations() {
					Model.shared.searchStopsVM.send(event: .didRecentStopsUpdated(recentStops: stops))
				}
				if let recentSearches = coreDataStore.fetchRecentSearches() {
					Model.shared.recentSearchesVM.send(event: .didUpdateData(recentSearches))
				}
				if let chewJourneys = coreDataStore.fetchJourneys() {
					Model.shared.journeyFollowVM.send(
						event: .didUpdateData(
							chewJourneys.compactMap{$0.journeyFollowData()}
						)
					)
				}
			}
			if let settings = coreDataStore.fetchSettings() {
				return Just(Event.didLoadInitialData(settings))
					.eraseToAnyPublisher()
			} else {
				return Just(Event.didLoadInitialData(.init()))
					.eraseToAnyPublisher()
			}
		}
	}
}

