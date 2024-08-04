//
//  JourneyDetailsVM+sideEffect.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Foundation
import Combine
import CoreLocation
import MapKit

extension JourneyDetailsViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		} 
	}
	
	static 	func whenChangingSubscribitionType() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .changingSubscribingState(id,_, vm) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			switch Model.shared.journeyFollowVM.state.journeys.contains(where: {$0.id == id}) == true {
			case true:
				Model.shared.journeyFollowVM.send(
					event: .didTapEdit(
						action: .deleting,
						followId: id,
						followData: nil,
						sendToJourneyDetailsViewModel: { event in
							vm?.send(event: event)
						}
					)
				)
			case false:
				Model.shared.journeyFollowVM.send(
					event: .didTapEdit(
						action: .adding,
						followId : id,
						followData: JourneyFollowData(
							id : id,
							journeyViewData: state.data.viewData,
							stops: .init(
								departure: state.data.depStop,
								arrival: state.data.arrStop
							),
							journeyActions: state.data.viewData.journeyActions()
						),
						sendToJourneyDetailsViewModel: { event in
							vm?.send(event: event)
						}
					)
				)
			}
			return Empty().eraseToAnyPublisher()
		}
	}
}
