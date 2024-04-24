//
//  SearchJourneyVM+reduce+.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation

extension ChewViewModel {
	static func reduceEditingStop(_ state:  State, _ event: Event) -> State {
		guard case .editingStop(let type) = state.status else { return state }
		switch event {
		case .onJourneyDataUpdated,
				.didLoadInitialData,
				.didReceiveLocationData,
				.didFailToLoadLocationData,
				.didStartViewAppear,
				.onNotEnoughSearchData,
				.didTapCloseJourneyList:
			logReducerWarning(event, state.status)
			return state
		case .didCancelEditStop:
			return State(state: state, status: .idle)
		case .onStopEdit(let type):
			return State(state: state, status: .editingStop(type))
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
		case .onStopsSwitch:
			return State(
				data: StateData(
					data: state.data,
					depStop: state.data.arrStop,
					arrStop: state.data.depStop),
				status: .editingStop(type.next())
			)
		case .didLocationButtonPressed(send: let send):
			switch Model.shared.searchStopsVM.state.status {
			case .loading:
				return State(state: state, status: .idle)
			default:
				return State(state: state, status: .loadingLocation(send: send))
			}
		}
	}
}
