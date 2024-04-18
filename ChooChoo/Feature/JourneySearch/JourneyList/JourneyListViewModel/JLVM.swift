//
//  SearchStopViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 03.09.23.
//

import Foundation
import Combine
import SwiftUI

class JourneyListViewModel : ChewViewModelProtocol {
	let id = UUID()
	@Published private(set) var state : State {
		didSet {
			Self.log(state.status)
		}
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
//	// testing init
//	init(stops : DepartureArrivalPairStop,viewData : JourneyListViewData) {
//		state = State(
//			journeys: viewData.journeys,
//			date: .init(date: .now, mode: .departure),
//			earlierRef: nil,
//			laterRef: nil,
//			settings: JourneySettings(),
//			stops: stops,
//			status: .journeysLoaded
//		)
//		Publishers.system(
//			initial: state,
//			reduce: Self.reduce,
//			scheduler: RunLoop.main,
//			feedbacks: [
//				Self.userInput(input: input.eraseToAnyPublisher()),
//				Self.whenLoadingJourneyRef(),
//				Self.whenLoadingJourneyList()
//			],
//			name: "JLVM"
//		)
//		.assign(to: \.state, on: self)
//		.store(in: &bag)
//	}
	
	init(
		date: SearchStopsDate,
		settings : JourneySettings,
		stops : DepartureArrivalPairStop
	) {
		state = State(
			journeys: [],
			date: date,
			earlierRef: nil,
			laterRef: nil,
			settings: settings,
			stops: stops,
			status: .loadingJourneyList
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenLoadingJourneyRef(),
				Self.whenLoadingJourneyList()
			]
		)
		.weakAssign(to: \.state, on: self)
		.store(in: &bag)
	}
	deinit {
		bag.removeAll()
	}
	
	func send(event: Event) {
		input.send(event)
	}
}
