//
//  JourneyDetailsVM+reduce.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Foundation
extension JourneyDetailsViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.status)
		switch state.status {
		case .changingSubscribingState:
			switch event {
			case .didFailToChangeSubscribingState:
				return State(
					data: state.data,
					status: .error(error: ChooNetworking.ApiError.cannotDecodeRawData)
				)
			case .didChangedSubscribingState:
				return State(
					data: StateData(currentData: state.data),
					status: .loadedJourneyData
				)
			default:
				logReducerWarning(event, state.status)
				return state
			}
			
		case .loading, .loadingIfNeeded:
			switch event {
			case .didCancelToLoadData:
				return State(
					data: state.data,
					status: .loadedJourneyData
				)
			case let .didTapReloadButton(id,ref):
				return State(
					data: state.data,
					status: .loading(id: id,token: ref)
				)
			case let .didRequestReloadIfNeeded(id, ref, status):
				return State(
					data: state.data,
					status: .loadingIfNeeded(id: id,token: ref,timeStatus: status)
				)
			case .didLoadJourneyData(let data):
				return State(
					data: StateData(currentData: state.data, viewData: data),
					status: .loadedJourneyData
				)
			case .didFailedToLoadJourneyData(let error):
				return State(
					data: state.data,
					status: .error(error: error)
				)
			default:
				logReducerWarning(event, state.status)
				return state
			}
			
		case .loadedJourneyData:
			switch event {
			case let .didTapSubscribingButton(id,ref, vm):
				return State(
					data: state.data,
					status: .changingSubscribingState(id: id, ref: ref, journeyDetailsViewModel: vm)
				)
			case let .didTapReloadButton(id,ref):
				return State(
					data: state.data,
					status: .loading(id:id,token: ref)
				)
			case let .didRequestReloadIfNeeded(id, ref, status):
				return State(
					data: state.data,
					status: .loadingIfNeeded(id: id,token: ref,timeStatus: status)
				)
			default:
				logReducerWarning(event, state.status)
				return state
			}
			
		case .error:
			switch event {
			case let .didTapSubscribingButton(id,ref, vm):
				return State(
					data: state.data,
					status: .changingSubscribingState(id: id, ref: ref, journeyDetailsViewModel: vm)
				)
			case
					.didLoadJourneyData,
					.didFailedToLoadJourneyData:
				logReducerWarning(event, state.status)
				return state
			case let .didRequestReloadIfNeeded(id, ref, status):
				return State(
					data: state.data,
					status: .loadingIfNeeded(id: id,token: ref,timeStatus: status)
				)
			case let .didTapReloadButton(id,ref):
				return State(
					data: state.data,
					status: .loading(id:id,token: ref)
				)
			default:
				logReducerWarning(event, state.status)
				return state
			}
		}
	}
}
