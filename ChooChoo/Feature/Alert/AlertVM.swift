//
//  ALertVM.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 17.01.24.
//

import Foundation
import Combine
import Network
import SwiftUI

class AlertViewModel : ChewViewModelProtocol {

	@Published private(set) var state : State {
		didSet { Self.log(state.alert) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init() {
		self.state = State(alert: .none)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher())
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



extension AlertViewModel {
	enum AlertType : ChewStatus {
		case none
		case destructive(
			destructiveAction : ()->Void,
			description : String,
			actionDescription : String,
			id : UUID,
			presentedOn: ContentView.ConfirmationDialogType
		)
		case action(
			action : ()->Void,
			description : String,
			actionDescription : String,
			id : UUID
		)
		case info(title : String, msg : String)

		var description : String {
			switch self {
			case .none:
				return "none"
			case let .info(title, _):
				return "info \(title)"
			case let .action(_,name,_,id):
				return "action \(name) \(id)"
			case let .destructive(_,name,_,id, type):
				return "destructive \(name) \(id) \(type.rawValue)"
			}
		}
	}
	
	struct State : Equatable {
		let alert : AlertType
	}
	
	enum Event : ChewEvent {
		case didRequestDismiss
		case didRequestShow(_ type: AlertType)
		var description : String {
			switch self {
			case .didRequestDismiss:
				return "didTapDismiss"
			case .didRequestShow:
				return "didRequestShow"
			}
		}
	}
}


extension AlertViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.alert)
		switch event {
		case .didRequestShow(let type):
			return State(alert: type)
		case .didRequestDismiss:
			return State(alert: .none)
		}
	}
}

extension AlertViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
}

