//
//  VMTemplate.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.01.24.
//

import Foundation
import Combine
import OSLog

class ViewModel : ChewViewModelProtocol ,ObservableObject, Identifiable {
	@Published private(set) var state : State {
		didSet {
			Self.log(state.status)
		}
	}

	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	
	init(_ initaialStatus : Status = .start) {
		self.state = State(
			status: initaialStatus
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
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

extension ViewModel  {
	struct State {
		let status : Status

		init(status: Status) {
			self.status = status
		}
	}
	
	enum Status : ChewStatus {
		static func == (lhs: ViewModel.Status, rhs: ViewModel.Status) -> Bool {
			return lhs.description == rhs.description
		}
		case start
		
		var description : String {
			switch self {
			case .start:
				return "start"
			}
		}
	}
	
	enum Event : ChewEvent {
		case didLoadInitialData
		
		var description : String {
			switch self {
			case .didLoadInitialData:
				return "didLoadInitialData"
			}
		}
	}
}


extension ViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		switch state.status {
		case .start:
			switch event {
			case .didLoadInitialData:
				return state
			}
		}
	}
}

extension ViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
}
