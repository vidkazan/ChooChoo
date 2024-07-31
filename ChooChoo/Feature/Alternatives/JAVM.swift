//
//  JAVM.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 30.07.24.
//

import Foundation
import Combine
import OSLog

class JourneyAlternativeViewModel : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}

	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init(_ initaialStatus : Status = .idle) {
		self.state = State(
			status: initaialStatus,
			data: nil
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

extension JourneyAlternativeViewModel  {
	struct State {
		let status : Status
		let data : JourneyAlternativeViewData?
		init(status: Status, data : JourneyAlternativeViewData?) {
			self.status = status
			self.data = data
		}
	}
	
	enum Status : ChewStatus {
		case idle
		case loading(jvd : JourneyViewData, referenceDate : ChewDate, send : (Event) -> ())
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
		case didUpdateJourneyData(data : JourneyViewData, referenceDate : ChewDate, send : (Event) -> ())
		case didLoad(data : JourneyAlternativeViewData)
		case didFailToLoad(error : any ChewError)
		
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


extension JourneyAlternativeViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		switch state.status {
		case .idle,.error:
			switch event {
			case let .didUpdateJourneyData(data,referenceDate,send):
				return State(status: .loading(jvd: data, referenceDate: referenceDate, send: send), data: state.data)
			case .didLoad:
				return state
			case .didFailToLoad:
				return state
			}
		case .loading:
			switch event {
			case let .didUpdateJourneyData(data,referenceDate,send):
				return State(status: .loading(jvd: data, referenceDate: referenceDate, send: send), data: state.data)
			case .didLoad(let data):
				return State(status: .idle, data: data)
			case .didFailToLoad(let error):
				return State(status: .error(error: error), data: state.data)
			}
		}
	}
}

extension JourneyAlternativeViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	static func whenLoading() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .loading(jvd, referenceDate,send) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			Task {
				if let res = Self.getAlternativeJourneyDepartureStop(journey: jvd, referenceDate: referenceDate) {
					return send(Event.didLoad(data: res))
				}
				return send(Event.didFailToLoad(error: DataError.nilValue(type: "alternative data is nil")))
			}
			return Empty().eraseToAnyPublisher()
		}
	}
}
