//
//  ChewVM+reduce+Idle.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation

extension ChewViewModel {
	static func reduceIdle(_ state:  State, _ event: Event) -> State {
		guard case .idle = state.status else { return state }
		switch event {
		case .didLoadInitialData,
				.didStartViewAppear,
				.didReceiveLocationData,
				.didCancelEditStop,
				.didFailToLoadLocationData,
				.didTapCloseJourneyList,
				.onNotEnoughSearchData:
			logReducerWarning(event, state.status)
			return state
		case .onJourneyDataUpdated(let stops):
			return State(state: state, status: .journeys(stops))
		case .onStopEdit(let type):
			return State(state: state, status: .editingStop(type))
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
		case .didLocationButtonPressed(send: let send):
			return State(state: state, status: .loadingLocation(send: send))
		}
	}
}

