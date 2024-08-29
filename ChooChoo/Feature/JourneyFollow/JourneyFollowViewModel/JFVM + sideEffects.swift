//
//  JourneyFollowViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.12.23.
//

import Foundation
import Combine

extension JourneyFollowViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	
	static func whenUpdatingJourney(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .updatingJourney(viewData, followId) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			
			var followData = state.journeys
			
			guard let index = followData.firstIndex(where: {$0.id == followId}) else {
				return Just(
					Event.didFailToUpdateJourney(Error.notFoundInFollowList(""))
				).eraseToAnyPublisher()
			}
			
			let oldViewData = followData[index]
			guard coreDataStore.updateJourney(
				id: followId,
				viewData: viewData,
				stops: oldViewData.stops
			) == true else {
				return Just(
					Event.didFailToUpdateJourney(
						CoreDataError.failedToUpdateDatabase(type: CDJourney.self)
					)
				).eraseToAnyPublisher()
			}
			
			followData[index] = JourneyFollowData(
				id: oldViewData.id,
				journeyViewData: viewData,
				stops: oldViewData.stops,
				journeyActions: viewData.journeyActions()
			)
			
			return Just(Event.didUpdateData(followData)).eraseToAnyPublisher()
		}
	}
	
	static func whenEditing(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
		Feedback {  (state: State) -> AnyPublisher<Event, Never> in
			guard case let .editing(action,followId, viewData,send) = state.status else {
				return Empty().eraseToAnyPublisher()
			}

			var journeys = state.journeys
			switch action {
			case .adding:
				guard let viewData = viewData else {
					send(.didFailToChangeSubscribingState(error: DataError.nilValue(type: "viewData")))
					return Just(Event.didFailToEdit(
						action: action,
						error: DataError.nilValue(type: "view data is nil")
					)).eraseToAnyPublisher()
				}
				guard !journeys.contains(where: {$0.id == followId}) else {
					send(.didFailToChangeSubscribingState(
						error: Error.alreadyContains("journey has been followed already")
					))
					return Just(Event.didFailToEdit(
						action: action,
						error: Error.alreadyContains("journey has been followed already")
					)).eraseToAnyPublisher()
				}
				guard
					coreDataStore.addJourney(
						id : viewData.id,
						viewData: viewData.journeyViewData,
						stops: viewData.stops
					) == true
				else {
					send(.didFailToChangeSubscribingState(
						error: CoreDataError.failedToAdd(type: CDJourney.self)
					))
					return Just(Event.didFailToEdit(
						action: action,
						error: CoreDataError.failedToAdd(type: CDJourney.self)
					)).eraseToAnyPublisher()
				}
				journeys.append(viewData)
				send(.didChangedSubscribingState)
				return Just(Event.didEdit(data: journeys))
					.eraseToAnyPublisher()
			case .deleting:
				guard let index = journeys.firstIndex(where: { $0.id == followId} ) else {
					send(.didFailToChangeSubscribingState(error: Error.notFoundInFollowList("not found in follow list to delete")))
					return Just(Event.didFailToEdit(
						action: action,
						error: Error.notFoundInFollowList("not found in follow list to delete")
					)).eraseToAnyPublisher()
				}
				guard coreDataStore.deleteJourneyIfFound(id: followId) == true else {
					send(.didFailToChangeSubscribingState(error: CoreDataError.failedToDelete(type: CDJourney.self)))
					return Just(Event.didFailToEdit(
						action: action,
						error: CoreDataError.failedToDelete(type: CDJourney.self)
					)).eraseToAnyPublisher()
				}
				journeys.remove(at: index)
				send(.didChangedSubscribingState)
				return Just(
					Event.didEdit(data: journeys)
				)
					.eraseToAnyPublisher()
			}
		}
	}
}
