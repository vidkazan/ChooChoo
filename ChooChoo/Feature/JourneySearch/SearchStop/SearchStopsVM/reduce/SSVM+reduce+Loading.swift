//
//  SearchLocationVM+reduce+Loading.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation


extension SearchStopsViewModel {
	static func reduceLoading(_ state:  State, _ event: Event) -> State {
		guard case .loading = state.status else { return state }
		switch event {
		case .didChangeFieldFocus(type: let type):
			return State(
				previousStops: state.previousStops,
				stops: state.stops,
				status: state.status,
				type: type
			)
		case .onDataLoaded(let stops, let type):
			return State(
				previousStops: state.previousStops,
				stops: stops,
				status: .loaded,
				type: type
			)
		case .onDataLoadError(let error):
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .error(error),
				type: state.type
			)
		case .onSearchFieldDidChanged(let string, let type):
			return State(
				previousStops: state.previousStops,
				stops: state.stops,
				status: .loading(string),
				type: type
			)
		case .onReset:
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .idle,
				type: state.type
			)
		case .onStopDidTap:
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .idle,
				type: nil
			)
		case .didRecentStopsUpdated,.didRequestDeleteRecentStop:
			logReducerWarning(event, state.status)
			return state
		}
	}
}
