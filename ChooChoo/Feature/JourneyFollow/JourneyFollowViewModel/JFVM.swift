//
//  JourneyFollowViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.12.23.
//

import Foundation
import Combine
import SwiftUI

struct JourneyFollowData : Hashable {
	let id : Int64
	let journeyViewData : JourneyViewData
	let stops : DepartureArrivalPairStop
	let journeyActions : [JourneyAction]
	
	init(id: Int64, journeyViewData: JourneyViewData, stops : DepartureArrivalPairStop,journeyActions : [JourneyAction]) {
		self.id = id
		self.journeyViewData = journeyViewData
		self.stops = stops
		self.journeyActions = journeyActions
	}
}

final class JourneyFollowViewModel : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet {
			Self.log(state.status)
		}
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	init(
		journeys : [JourneyFollowData],
		initialStatus : Status = .updating,
		coreDataStore : CoreDataStore
	) {
		state = State(
			journeys: journeys,
			status: initialStatus
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenEditing(coreDataStore: coreDataStore),
				Self.whenUpdatingJourney(coreDataStore: coreDataStore)
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

extension JourneyFollowViewModel {
	struct State : Equatable {
		var journeys : [JourneyFollowData]
		var status : Status
		
		init(journeys: [JourneyFollowData], status: Status) {
			self.journeys = journeys
			self.status = status
		}
	}
	
	enum Action : String {
		case adding
		case deleting

		var text : Text {
			switch self {
			case .adding:
				return Text("follow",comment: "JourneyFollowViewModel.Action")
			case .deleting:
				return Text("unfollow",comment: "JourneyFollowViewModel.Action")
			}
		}
	}
	
	enum Status : ChewStatus {
		case error(error : String)
		case idle
		case editing(_ action: Action, followId : Int64, followData : JourneyFollowData?,sendToJourneyDetailsViewModel : (JourneyDetailsViewModel.Event)->Void)
		case updating
		case updatingJourney(_ viewData : JourneyViewData,_ followId : Int64)
		
		var description : String {
			switch self {
			case let .updatingJourney(viewData, _):
				return "updatingJourney \(viewData.destination)"
			case .error(let error):
				return "error \(error.description)"
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
		case didFailToEdit(action : Action, error : any ChewError)
		case didTapUpdate
		case didUpdateData([JourneyFollowData])
		case didRequestUpdateJourney(JourneyViewData, Int64)
		case didFailToUpdateJourney(_ error : any ChewError)
		
		case didTapEdit(
			action : Action,
			followId : Int64,
			followData : JourneyFollowData?,
			sendToJourneyDetailsViewModel : (JourneyDetailsViewModel.Event)->Void
		)
		case didEdit(data : [JourneyFollowData])
			
		var description : String {
			switch self {
			case let .didRequestUpdateJourney(viewData, _):
				return "didRequestUpdateJourney \(viewData.origin) \(viewData.destination)"
			case .didFailToUpdateJourney(let error):
				return "didFailToUpdateJourney \(error.localizedDescription)"
			case .didFailToEdit(action: let action, error: let error):
				return "didFailToEdit: \(action): \(error)"
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
	
	enum Error : ChewError {
		static func == (lhs: Error, rhs: Error) -> Bool {
			return lhs.description == rhs.description
		}
		
		func hash(into hasher: inout Hasher) {
			switch self {
			case 
				.alreadyContains,
				.notFoundInFollowList:
				break
			}
		}
		case alreadyContains(_ msg: String)
		case notFoundInFollowList(_ msg: String)
		
		
		var description : String  {
			switch self {
			case.alreadyContains(let msg):
				return "Already contains: \(msg)"
			case .notFoundInFollowList(let msg):
				return "notFoundInFollowList: \(msg)"
			}
		}
	}
}
