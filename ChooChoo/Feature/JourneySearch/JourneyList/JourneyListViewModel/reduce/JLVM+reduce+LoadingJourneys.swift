//
//  SearchJourneyVM+reduce+3.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation


extension JourneyListViewModel {
	static func reduceLoadingJourneyList(_ state:  State, _ event: Event) -> State {
		guard case .loadingJourneyList = state.status else { return state }
		switch event {
		case .onNewJourneyListData(let data, let type):
			switch type {
			case .initial:
				return State(
					data: StateData(
						stops: state.data.stops,
						date: state.data.date,
						settings: state.data.settings,
						journeys: data.journeys,
						earlierRef: data.earlierRef,
						laterRef: data.laterRef
					),
					status: .journeysLoaded
				)
			default:
				return state
			}
		case .onFailedToLoadJourneyListData(let err):
			return State(
				data: state.data,
				status: .failedToLoadJourneyList(err)
			)
		case .onReloadJourneyList:
			logReducerWarning(event, state.status)
			return state
		case .onLaterRef:
			return state
		case .onEarlierRef:
			return state
		case .didFailToLoadLaterRef:
			return state
		case .didFailToLoadEarlierRef:
			return state
		}
	}
}
