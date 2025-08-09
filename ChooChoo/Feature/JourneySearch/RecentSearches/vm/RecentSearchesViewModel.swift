//
//  RecentSearchesViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 20.01.24.
//

import Foundation
import Combine

final class RecentSearchesViewModel : ChewViewModelProtocol {
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
		didSet {
			Self.log(state.status)
		}
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	private let coreDataStore : CoreDataStore
	
	init(
		searches : [RecentSearch],
		coreDataStore : CoreDataStore
	) {
		self.coreDataStore = coreDataStore
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
				Self.whenEditing(coreDataStore: coreDataStore)
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
	
	enum Status : ChewStatus {
		case error(action : String, error : any ChewError)
		case idle
		case editing(_ action: Action, search : RecentSearch?)
		case updating
		
		var description : String {
			switch self {
			case let .error(action, error):
				return "error \(action.description) \(error.localizedDescription)"
			case .idle:
				return "idle"
			case .updating:
				return "updating"
			case .editing:
				return "editing"
			}
		}
	}
	
	enum Event : ChewEvent {
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
			case .didFailToEdit(let action,let msg):
				return "didFailToEdit \(action) \(msg)"
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
	static func whenEditing(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			switch state.status {
			case .editing(let action, let data):
				var searches = state.searches
				switch action {
				case .adding:
					guard let data = data else {
						return Just(Event.didFailToEdit(action: action,msg: "data is nil")).eraseToAnyPublisher()
					}
                        
                    // If a a pair depStop - arrStop already exists, we update the position of the search
					if let index = searches.firstIndex(where: {
						return $0.stops.id == data.stops.id
					}) {
						let search = searches[index]
						let updatedSearch = RecentSearchesViewModel.RecentSearch(
                            stops: search.stops,
                            searchTS: Date.now.timeIntervalSince1970
                        )
						searches.remove(at: index)
						searches.append(updatedSearch)
						if Model.shared.coreDataStore.updateRecentSearchTS(
                            search: updatedSearch
                        ) != true {
							return Just(
                                Event.didFailToEdit(
                                    action: action,
                                    msg: "coredata: failed to update"
                                )
                            ).eraseToAnyPublisher()
						}
						return Just(Event.didEdit(data: searches))
							.eraseToAnyPublisher()
					}
                    
					guard coreDataStore.addRecentSearch(search: data) == true else {
						return Just(
                            Event.didFailToEdit(
                                action: action,
                                msg: "coredata: failed to add"
                            )
                        ).eraseToAnyPublisher()
					}
					
					searches.append(data)
                        
                        
                    if let recentSearches = coreDataStore.fetchRecentSearches() {
                        let recentSearchesCount = recentSearches.count
                        if recentSearchesCount > 5 {
                            let itemsToDelete = recentSearches.prefix(recentSearchesCount - 5)
                            itemsToDelete.forEach { item in
                                if coreDataStore.deleteRecentSearchIfFound(id: item.stops.id) != true {
                                    Self.warning(Self.Status.updating, "failed to delete recent search")
                                }
                            }
                        }
                    }
                        
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
						coreDataStore.deleteRecentSearchIfFound(id: id) == true
					else {
						return Just(Event.didFailToEdit(action: action,msg: "not found in db to delete")).eraseToAnyPublisher()
					}
					searches.remove(at: index)
					return Just(Event.didEdit(data: searches))
						.eraseToAnyPublisher()
				}
			default:
				return Empty().eraseToAnyPublisher()
			}
		}
	}
}

extension RecentSearchesViewModel {
	func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.status)
		switch state.status {
		case .idle,.error:
			switch event {
			case .didEdit,.didFailToEdit:
				Self.logReducerWarning(event, state.status)
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
