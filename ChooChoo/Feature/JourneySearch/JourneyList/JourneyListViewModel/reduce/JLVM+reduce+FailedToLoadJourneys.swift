//
//  SearchJourneyVM+reduce+.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation


extension JourneyListViewModel {
	static func reduceFailedToLoadJourneyList(_ state:  State, _ event: Event) -> State {
		guard case .failedToLoadJourneyList = state.status else { return state }
		switch event {
		case .onReloadJourneyList:
			return State(
				data: state.data,
				status: .loadingJourneyList
			)
		default:
			logReducerWarning(event, state.status)
			return state
		}
	}
}

