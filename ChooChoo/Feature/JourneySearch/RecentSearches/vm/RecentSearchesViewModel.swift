//
//  RecentSearchesViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 20.01.24.
//

import Foundation
import Combine

final class RecentSearchesViewModel : ObservableObject, Identifiable {
	struct RecentSearch : Equatable {
		let stops : DepartureArrivalPairStop
		let searchTS : Double
		
		init(stops: DepartureArrivalPairStop, searchTS: Double) {
			self.stops = stops
			self.searchTS = searchTS
		}
		init(depStop : Stop,arrStop : Stop, searchTS: Double) {
			self.stops = DepartureArrivalPairStop(departure: depStop, arrival: arrStop)
			self.searchTS = searchTS
		}
	}
	
	@Published private(set) var state : State {
		didSet { print("⏳🚂 >  state:",state.status.description) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init(
		searches : [RecentSearch]
	) {
		state = State(
			searches: searches,
			status: .updating
		)
		Publishers.system(
			initial: state,
			reduce: self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenEditing()
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

extension RecentSearchesViewModel {
	struct State : Equatable {
		
		var searches : [RecentSearch]
		var status : Status
		
		init(searches: [RecentSearch], status: Status) {
			self.searches = searches
			self.status = status
		}
	}
	
	enum Action : String {
		case adding
		case deleting
	}
	
	enum Status : Equatable {
		static func == (lhs: RecentSearchesViewModel.Status, rhs: RecentSearchesViewModel.Status) -> Bool {
			return lhs.description == rhs.description
		}
		case error(error : String)
		case idle
		case editing(_ action: Action, search : RecentSearch?)
		case updating
		
		var description : String {
			switch self {
			case .error(let action):
				return "error \(action.description)"
			case .idle:
				return "idle"
			case .updating:
				return "updating"
			case .editing:
				return "editing"
			}
		}
	}
	
	enum Event {
		case didFailToEdit(action : Action, msg: String)
		case didTapUpdate
		case didUpdateData([RecentSearch])
		
		case didTapEdit(
			action : Action,
			search : RecentSearch?
		)
		case didEdit(data : [RecentSearch])
		
		var description : String {
			switch self {
			case .didFailToEdit:
				return "didFailToEdit"
			case .didEdit:
				return "didEdit"
			case .didTapEdit:
				return "didTapEdit"
			case .didTapUpdate:
				return "didTapUpdate"
			case .didUpdateData:
				return "didUpdatedData"
			}
		}
	}
}


extension RecentSearchesViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	static func whenEditing() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			switch state.status {
			case .editing(let action, let data):
				var searches = state.searches
				switch action {
				case .adding:
					guard let data = data else {
						return Just(Event.didFailToEdit(action: action,msg: "data is nil")).eraseToAnyPublisher()
					}
					guard !searches.contains(where: {
						return $0.stops.id == data.stops.id
					}) else {
						return Just(Event.didFailToEdit(action: action,msg: "search been added already")).eraseToAnyPublisher()
					}
					
					guard Model.shared.coreDataStore.addRecentSearch(search: data) == true else {
						return Just(Event.didFailToEdit(action: action,msg: "coredata: failed to add")).eraseToAnyPublisher()
					}
					
					searches.append(data)
					return Just(Event.didEdit(data: searches))
						.eraseToAnyPublisher()
				case .deleting:
					guard let id = data?.stops.id else {
						return Just(Event.didFailToEdit(action: action,msg: "id is nil")).eraseToAnyPublisher()
					}
					guard
						let index = searches.firstIndex(where: {
							$0.stops.id == id
						} )
					else {
						return Just(Event.didFailToEdit(action: action,msg: "not found in list to delete")).eraseToAnyPublisher()
					}
					guard
						Model.shared.coreDataStore.deleteRecentSearchIfFound(id: id) == true
					else {
						return Just(Event.didFailToEdit(action: action,msg: "not found in db to delete")).eraseToAnyPublisher()
					}
					searches.remove(at: index)
					return Just(Event.didEdit(data: searches))
						.eraseToAnyPublisher()
				}
			default:
				return Empty()
					.eraseToAnyPublisher()
			}
		}
	}
}

extension RecentSearchesViewModel {
	func reduce(_ state: State, _ event: Event) -> State {
		print("⏳🚂🔥 > :",event.description,"state:",state.status.description)
		switch state.status {
		case .idle,.error:
			switch event {
			case .didEdit,.didFailToEdit:
				print("⚠️ \(Self.self): reduce error: \(state.status) \(event.description)")
				return state
			case .didTapUpdate:
				return state
			case .didUpdateData(let data):
				return State(
					searches: data,
					status: .idle
				)
			case .didTapEdit(action: let action, let data):
				return State(
					searches: state.searches,
					status: .editing(
						action,
						search: data
					)
				)
			}
		case .updating:
			switch event {
			case .didFailToEdit:
				return state
			case .didTapUpdate:
				return state
			case .didUpdateData(let data):
				return State(
					searches: data,
					status: .idle
				)
			case .didEdit:
				return state
			case .didTapEdit(action: let action, let data):
				return State(
					searches: state.searches,
					status: .editing(
						action,
						search: data
					)
				)
			}
		case .editing:
			switch event {
			case .didFailToEdit:
				return State(
					searches: state.searches,
					status: .idle
				)
			case .didTapUpdate:
				return state
			case .didUpdateData:
				return state
			case .didTapEdit:
				return state
			case .didEdit(let data):
				return State(
					searches: data,
					status: .idle
				)
			}
		}
	}
}
