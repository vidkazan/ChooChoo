//
//  SearchJourneyVM+reduce+.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation


extension ChewViewModel {
	static func reduceJourneyList(_ state:  State, _ event: Event) -> State {
		guard case .journeys = state.status else { return state }
		switch event {
		case .onStopsSwitch:
			return State(
				data: StateData(
					data: state.data,
					depStop: state.data.arrStop,
					arrStop: state.data.depStop),
				status: .checkingSearchData
			)
		case let .didUpdateSearchData(dep,arr,date,journeySettings):
			return State(
				data: StateData(
					data: state.data,
					depStop: dep,
					arrStop: arr,
					journeySettings: journeySettings,
					date: date
				),
				status: .checkingSearchData
			)
		case .onStopEdit(let type):
			return State(state: state, status: .editingStop(type))
		case .didTapCloseJourneyList:
			return State(state: state, status: .idle)
		case .didLocationButtonPressed(send: let send):
			return State(state: state, status: .loadingLocation(send: send))
		case .didReceiveLocationData,
			 .didFailToLoadLocationData,
			 .didLoadInitialData,
			 .onJourneyDataUpdated,
			 .onNotEnoughSearchData,
			 .didCancelEditStop,
			 .didStartViewAppear:
			logReducerWarning(event, state.status)
			return state
		}
	}
}

