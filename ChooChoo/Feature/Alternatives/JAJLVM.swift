//
//  JAJLVM.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 31.07.24.
//

import Foundation
import Combine
import OSLog
import SwiftUI

class JourneyAlternativeJourneysListViewModel : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}
	
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init(
		_ initaialStatus : Status = .idle,
		arrStop : Stop,
		depStop : ChooDeparture,
		time : ChewDate,
		settings : JourneySettings
	) {
		self.state = State(
			status: initaialStatus,
			arrStop: arrStop,
			depStop: depStop,
			time: time,
			settings: settings,
			journeys: []
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenLoading()
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

extension JourneyAlternativeJourneysListViewModel  {
	struct State {
		let status : Status
		let journeys : [(JourneyViewData,ChooDeparture)]
		let arrStop : Stop
		let time : ChewDate
		let depStop : ChooDeparture
		let settings : JourneySettings
		let lastRequestTS : Double
		
		init(
			status: Status,
			arrStop : Stop,
			depStop : ChooDeparture,
			time : ChewDate,
			settings : JourneySettings,
			journeys : [(JourneyViewData,ChooDeparture)]
		) {
			self.time = time
			self.status = status
			self.journeys = journeys
			self.arrStop = arrStop
			self.depStop = depStop
			self.settings = settings
			self.lastRequestTS = 0
		}
		
		init(
			state : Self,
			status: Status,
			arrStop : Stop? = nil,
			depStop : ChooDeparture? = nil,
			time : ChewDate? = nil,
			settings : JourneySettings? = nil,
			journeys : [(JourneyViewData,ChooDeparture)]? = nil,
			lastRequestTS : Double? = nil
		) {
			self.status = status
			self.time = time ?? state.time
			self.journeys = journeys ?? state.journeys
			self.arrStop = arrStop ?? state.arrStop
			self.depStop = depStop ?? state.depStop
			self.settings = settings ?? state.settings
			self.lastRequestTS = lastRequestTS ?? state.lastRequestTS
		}
	}
	
	enum Status : ChewStatus {
		case idle
		case loading(referenceDate : ChewDate)
		case error(error : any ChewError)
		
		var description : String {
			switch self {
			case .idle:
				return "idle"
			case .loading:
				return "loading"
			case .error:
				return "error"
			}
		}
	}
	
	enum Event : ChewEvent {
		case didUpdateJourneyData(depStop : ChooDeparture, time : ChewDate, referenceDate : ChewDate)
		case didLoad(journeys : [(JourneyViewData,ChooDeparture)], requestTS : Double)
		case didFailToLoad(error : any ChewError,requestTS : Double)
		
		var description : String {
			switch self {
			case .didUpdateJourneyData:
				return "didUpdateJourneyData"
			case .didFailToLoad:
				return "didFailToLoad"
			case .didLoad:
				return "didLoad"
			}
		}
	}
}


extension JourneyAlternativeJourneysListViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		switch state.status {
		case .idle,.error:
			switch event {
			case let .didUpdateJourneyData(depStop,time,referenceDate):
				return State(
					state : state,
					status: .loading(referenceDate: referenceDate),
					depStop: depStop,
					time: time,
					lastRequestTS: referenceDate.ts
				)
			case .didLoad:
				return state
			case .didFailToLoad:
				return state
			}
		case .loading:
			switch event {
			case let .didUpdateJourneyData(depStop,time,referenceDate):
				return State(
					state : state,
					status: .loading(referenceDate: referenceDate),
					depStop: depStop,
					time: time,
					lastRequestTS: referenceDate.ts
				)
			case let .didLoad(journeys,ts):
				return State(state : state,status: .idle,journeys: journeys)
			case let .didFailToLoad(error,ts):
				return State(state : state,status: .error(error: error))
			}
		}
	}
}

extension JourneyAlternativeJourneysListViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	static func whenLoading() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .loading(referenceDate) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			return JourneyListViewModel.fetchJourneyList(
				dep: state.depStop,
				arr: state.arrStop,
				time: state.time.date,
				mode: .departure,
				settings: state.settings
			)
			.mapError({$0})
			.asyncFlatMap {
				if let src = $0.journeys {
					let res = src.compactMap({
						let viewData = $0.journeyViewData(
							depStop: state.depStop.stop,
							arrStop: state.arrStop,
							realtimeDataUpdatedAt: Date.now.timeIntervalSince1970,
							settings: state.settings
						)
						if let viewData = viewData {
							return (viewData,state.depStop)
						}
						return nil
					})
					return Event.didLoad(journeys: res,requestTS: referenceDate.ts)
				}
				return .didLoad(journeys: state.journeys,requestTS: referenceDate.ts)
			}
			.catch {
				Just(.didFailToLoad(error: $0 as! any ChewError, requestTS: referenceDate.ts)).eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
		}
	}
}
