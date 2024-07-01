//
//  LogVIewModel.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 19.04.24.
//

import Foundation
import SwiftUI
import Combine
import OSLog

class LogViewModel : ChewViewModelProtocol {
	static let logStore: OSLogStore? = try? OSLogStore(
		scope: .currentProcessIdentifier
	)
	static let position = logStore?
		.position(date: Date().addingTimeInterval(-86400))
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}

	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init(_ initaialStatus : Status = .loaded) {
		self.state = State(
			status: initaialStatus,
			entries: []
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

extension LogViewModel  {
	struct State {
		let status : Status
		let entries: [OSLogEntryLog]
		
		init(status: Status, entries : [OSLogEntryLog]) {
			self.status = status
			self.entries = entries
		}
	}
	
	enum Status : ChewStatus {
		case loading
		case loaded
		case error(any ChooError)
		
		var description : String {
			switch self {
			case .loading:
				return "loading"
			case .loaded:
				return "loaded"
			case .error(let err):
				return "error \(err.localizedDescription)"
			}
		}
	}
	
	enum Event : ChewEvent {
		case didTapLoading
		case didCancelLoading
		case didLoad(logs : [OSLogEntryLog])
		case didFailToLoad(error : any ChooError)
		
		var description : String {
			switch self {
			case .didTapLoading:
				return "didTapLoading"
			case .didCancelLoading:
				return "didCancelLoading"
			case .didFailToLoad:
				return "didFailToLoad"
			case .didLoad:
				return "didLoad"
			}
		}
	}
}


extension LogViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		switch state.status {
		case .loading:
			switch event {
			case .didTapLoading:
				return State(
					status: .loading,
					entries: state.entries
				)
			case .didCancelLoading:
				return State(
					status: .loaded,
					entries: state.entries
				)
			case .didLoad(let logs):
				return State(
					status: .loaded,
					entries: logs
				)
			case .didFailToLoad(let error):
				return State(
					status: .error(error),
					entries: state.entries
				)
			}
		case .loaded:
			switch event {
			case .didTapLoading:
				return State(
					status: .loading,
					entries: state.entries
				)
			default:
				return state
			}
		case .error:
			switch event {
			case .didTapLoading:
				return State(
					status: .loading,
					entries: state.entries
				)
			default:
				return state
			}
		}
	}
}

extension LogViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
}

extension LogViewModel {
	static func whenLoading() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loading = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			Task {
				if let ent = try? Self.logStore?.getEntries(at: position)  {
					let entries = ent
						.compactMap { elem in
							elem as? OSLogEntryLog
						}
						.filter { $0.subsystem.starts(with: Bundle.main.bundleIdentifier!)
						}
					if entries.isEmpty {
						return Model.shared.logVM.send(event: .didFailToLoad(error: DataError.generic(msg: "No logs found")))
					}
					return Model.shared.logVM.send(event: .didLoad(logs: entries))
				} else {
					return Model.shared.logVM.send(event: .didFailToLoad(error: DataError.generic(msg: "OSLogStore: Failed to get log entries")))
				}
			}
			return Empty().eraseToAnyPublisher()
		}
	}
}
