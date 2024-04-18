//
//  SearchLocationVM+reduce+Idle.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation

extension SearchStopsViewModel {
	static func reduceIdle(_ state:  State, _ event: Event) -> State {
		guard case .idle = state.status else { return state }
		switch event {
		case .didRequestDeleteRecentStop(stop: let stop):
			let	 stops = state.previousStops.filter({$0.name != stop.name})
			return State(
				previousStops: stops,
				stops: state.stops,
				status: state.status,
				type: state.type
			)
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
		case .onReset:
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .idle,
				type: state.type
			)
		case .onStopDidTap(let content,_):
			return State(
				previousStops: state.previousStops,
				stops: [],
				status: .updatingRecentStops(content.stop),
				type: nil
			)
		case .didRecentStopsUpdated(recentStops: let stops):
			return State(
				previousStops: stops,
				stops: state.stops,
				status: .idle,
				type: state.type
			)
		case
				.onDataLoaded,
				.onDataLoadError:
			logReducerWarning(event, state.status)
			return state
		}
	}
}


