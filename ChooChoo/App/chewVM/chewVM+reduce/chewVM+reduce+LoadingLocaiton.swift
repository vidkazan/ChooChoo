//
//  ChewVM+reduce+Idle.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation

extension ChewViewModel {
	static func reduceLoadingLocation(_ state:  State, _ event: Event) -> State {
		guard case .loadingLocation = state.status else { return state }
		switch event {
		case .didTapCloseJourneyList,
				.onJourneyDataUpdated,
				.didLoadInitialData,
				.didCancelEditStop,
				.didStartViewAppear,
				.onNotEnoughSearchData:
			logReducer(event, state.status)
			return state
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
		case .didLocationButtonPressed(_):
			return State(state: state, status: .idle)
		case .didReceiveLocationData(let stop):
			return State(data: StateData(data: state.data,depStop: .location(stop)), status: .checkingSearchData)
		case .didFailToLoadLocationData:
			return State(state: state, status: .idle)
		}
	}
}

