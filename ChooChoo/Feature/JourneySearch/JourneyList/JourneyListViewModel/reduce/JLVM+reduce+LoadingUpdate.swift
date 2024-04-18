//
//  SearchJourneyVM+reduce+3.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation


extension JourneyListViewModel {
	static func reduceLoadingUpdate(_ state:  State, _ event: Event) -> State {
		guard case .loadingRef = state.status else { return state }
		switch event {
		case .onNewJourneyListData(let data, let type):
			switch type {
			case .initial:
				logReducerWarning(event, state.status)
				return state
			case .earlierRef:
				return State(
					data: StateData(
						stops: state.data.stops,
						date: state.data.date,
						settings: state.data.settings,
						journeys: data.journeys + state.data.journeys,
						earlierRef: data.earlierRef,
						laterRef: data.laterRef
					),
					status: .journeysLoaded
				)
			case .laterRef:
				return State(
					data: StateData(
						stops: state.data.stops,
						date: state.data.date,
						settings: state.data.settings,
						journeys: state.data.journeys + data.journeys,
						earlierRef: data.earlierRef,
						laterRef: data.laterRef
					),
					status: .journeysLoaded
				)
			}
		case .onFailedToLoadJourneyListData(let err):
			return State(
				data: state.data,
				status: .failedToLoadJourneyList(err)
			)
		case .onReloadJourneyList:
			return state
		case .onLaterRef:
			return state
		case .onEarlierRef:
			return state
		case .didFailToLoadLaterRef(let error):
			return State(
				data: state.data,
				status: .failedToLoadLaterRef(error)
			)
		case .didFailToLoadEarlierRef(let error):
			return State(
				data: state.data,
				status: .failedToLoadEarlierRef(error)
			)
		}
	}
}
