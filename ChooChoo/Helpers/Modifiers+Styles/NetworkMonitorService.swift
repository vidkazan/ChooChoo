//
//  NetworkMonitorService.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.07.24.
//

import Foundation
import Combine
import OSLog
import Network


class NetworkMonitorService : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}

	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	private let apiMonitor : APIAvailabilityMonitor = .init()
	private let networkMonitor = NWPathMonitor()
	private let workerQueue = DispatchQueue(label: "Monitor")
	private let sendAlert : (TopBarAlertViewModel.Event) -> ()
	
	init(send : @escaping (TopBarAlertViewModel.Event)->Void) {
		self.sendAlert = send
		self.state = State(
			status: .ok
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenStatusChanged(sendAlert: self.sendAlert)
			]
		)
		.weakAssign(to: \.state, on: self)
		.store(in: &bag)
			
		apiMonitor.delegate = self
		networkMonitor.pathUpdateHandler = { self.handleNetworkUpdates(path:$0) }
		networkMonitor.start(queue: workerQueue)

	}
	
	
	private func handleNetworkUpdates(path : NWPath) {
		switch path.status {
		case .satisfied:
			self.send(event: .isOnline)
		case .unsatisfied:
			self.send(event: .isOffline)
		case .requiresConnection:
			self.send(event: .isOffline)
		@unknown default:
			self.send(event: .APICheckError(ApiError.generic(description: "NetworkMonitor: online status check error")))
		}
	}
	
	deinit {
		bag.removeAll()
	}

	func send(event: Event) {
		input.send(event)
	}
}

extension NetworkMonitorService  {
	struct State {
		let status : Status

		init(status: Status) {
			self.status = status
		}
	}
	
	enum Status : ChewStatus {
		case ok
		case offline
		case apiUnavailable
		case apiCheckError(any ChewError)
		
		var description : String {
			switch self {
			case .apiCheckError(let err):
				return "error: \(err.localizedDescription)"
			case .ok:
				return "ok"
			case .offline:
				return "offline"
			case .apiUnavailable:
				return "apiUnavailable"
			}
		}
	}
	
	enum Event : ChewEvent {
		case isOffline
		case isNotAPIAvailable
		case isOnline
		case isAPIAvailable
		case APICheckError(any ChewError)
		
		var description : String {
			switch self {
			case .isOffline:
				return "isOffline"
			case .isNotAPIAvailable:
				return "isNotAPIUnavailable"
			case .isOnline:
				return "isOnline"
			case .isAPIAvailable:
				return "isAPIAvailable"
			case .APICheckError:
				return "APICheckError"
			}
		}
	}
}


extension NetworkMonitorService {
	static func reduce(_ state: State, _ event: Event) -> State {
		switch state.status {
		case .apiCheckError:
			switch event {
			case .isOffline:
				return .init(status: .offline)
			case .isNotAPIAvailable:
				return state
			case .isOnline:
				return .init(status: .ok)
			case .isAPIAvailable:
				return .init(status: .ok)
			case .APICheckError(let err):
				return state
			}
		case .apiUnavailable:
			switch event {
			case .isOffline:
				return .init(status: .offline)
			case .isNotAPIAvailable:
				return state
			case .isOnline:
				return state
			case .isAPIAvailable:
				return .init(status: .ok)
			case .APICheckError(let err):
				return .init(status: .apiCheckError(err))
			}
		case .offline:
			switch event {
			case .isOffline:
				return state
			case .isNotAPIAvailable:
				return state
			case .isOnline:
				return .init(status: .ok)
			case .isAPIAvailable:
				return .init(status: .ok)
			case .APICheckError(let err):
				return .init(status: .apiCheckError(err))
			}
		case .ok:
			switch event {
			case .isOffline:
				return .init(status: .offline)
			case .isNotAPIAvailable:
				return .init(status: .apiUnavailable)
			case .isOnline:
				return state
			case .isAPIAvailable:
				return state
			case .APICheckError(let err):
				return .init(status: .apiCheckError(err))
			}
		}
	}
}

extension NetworkMonitorService {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	
	static func whenStatusChanged(sendAlert : @escaping (TopBarAlertViewModel.Event) -> ()) -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			switch state.status {
			case .ok:
//				sendAlert(.didRequestDismiss(.offline))
				sendAlert(.didRequestDismiss(.apiUnavailable))
			case .offline:
				sendAlert(.didRequestShow(.offline))
			case .apiUnavailable:
				sendAlert(.didRequestShow(.apiUnavailable))
			case .apiCheckError(_):
				sendAlert(.didRequestShow(.generic(msg: "Network Monitor Error")))
			}
			return Empty().eraseToAnyPublisher()
		}
	}
}

extension NetworkMonitorService : APIAvailabilityMonitorDelegate {
	func didUpdate(status: APIAvailabilityMonitor.State) {
		switch status {
		case .error(let chewError):
			self.send(event: .APICheckError(chewError))
		case .available:
			self.send(event: .isAPIAvailable)
		case .unavailable:
			self.send(event: .isNotAPIAvailable)
		}
	}
}
