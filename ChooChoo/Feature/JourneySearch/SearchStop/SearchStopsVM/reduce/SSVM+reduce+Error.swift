//
//  SearchLocationVM+reduce+Error.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation

extension SearchStopsViewModel {
	static func reduceError(_ state:  State, _ event: Event) -> State {
		guard case .error = state.status else { return state }
		switch event {
		case .didChangeFieldFocus(type: let type):
			return State(
				previousStops: state.previousStops,
				stops: state.stops,
				status: state.status,
				type: type
			)
		case .onSearchFieldDidChanged(let string, let type):
			return State(
				previousStops: state.previousStops,
				stops: state.stops,
				status: .loading(string),
				type: type
			)
		case .onStopDidTap:
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .idle,
				type: nil
			)
		case .onDataLoaded, .onDataLoadError,.didRecentStopsUpdated, .didRequestDeleteRecentStop:
			logReducerWarning(event, state.status)
			return state
		case .onReset:
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .idle,
				type: state.type
			)
		}
	}
}
