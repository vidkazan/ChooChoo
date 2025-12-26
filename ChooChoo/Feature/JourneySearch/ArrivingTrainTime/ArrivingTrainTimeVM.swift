//
//  ArrivingTrainTimeVM.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.03.24.
//

import Foundation
import Combine

class ArrivingTrainTimeViewModel : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	
	init(_ initaialStatus : Status = .idle, time : Prognosed<Date>? = nil) {
		self.state = State(
			status: initaialStatus,
			time: time
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

extension ArrivingTrainTimeViewModel  {
	struct State  {
		let time : Prognosed<Date>?
		let status : Status

		init(status: Status,time : Prognosed<Date>?) {
			self.status = status
			self.time = time
		}
	}
	
	enum Status : ChewStatus {
		case idle
		case loading(leg : LegViewData)
		case error(any ChewError)
		
		var description : String {
			switch self {
			case .idle:
				return "idle"
			case .loading:
				return "loading"
			case .error(let error):
				return "error \(error.localizedDescription)"
			}
		}
	}
	
	enum Event : ChewEvent {
		case didRequestTime(leg : LegViewData)
		case didCancelRequestTime
		case didLoad(time : Prognosed<Date>)
		case didFail(any ChewError)
		
		var description : String {
			switch self {
			case .didRequestTime:
				return "didRequestTime"
			case .didCancelRequestTime:
				return "didCancelRequestTime"
			case .didLoad:
				return "didLoad"
			case .didFail:
				return "didFail"
			}
		}
	}
}


extension ArrivingTrainTimeViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.status)
		switch state.status {
		case .idle,.error:
			switch event {
			case .didRequestTime(let leg):
				return State(
					status: .loading(leg: leg),
					time: nil
				)
			default:
				return state
			}
		case .loading:
			switch event {
			case .didCancelRequestTime:
				return State(status: .idle,time: nil)
			case .didLoad(let time):
				return State(status: .idle, time: time)
			case .didFail(let err):
				return State(status: .error(err),time: nil)
			default:
				return state
			}
		}
	}
}

extension ArrivingTrainTimeViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	static func whenLoading() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .loading(leg) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
	
			guard leg.legStopsViewData[0].time.date.arrival.planned == nil,
				let searchArrStop = leg.legStopsViewData[0].stop(),
				let searchDepStop = leg.legStopsViewData[1].stop(),
				let searchArrivalTime = leg.time.date.departure.actual,
				leg.lineViewData.type == .regional || leg.lineViewData.type == .suburban,
				let stop = leg.legStopsViewData.first,
				  let searchArrivalPlatform = leg.legStopsViewData[0].platforms.departure.actual
			else {
				return Just(Event.didFail(DataError.validationError(msg: "request validation filed"))).eraseToAnyPublisher()
			}
			
            let request = JourneyRequestIntBahnDe(
                settings: .init(
                    customTransferModes: .init([
                        .regional,.suburban
                    ]),
                    transportMode: .regional,
                    transferTime: .direct,
                    transferCount: .one,
                    accessiblity: .partial,
                    walkingSpeed: .fast,
                    startWithWalking: false,
                    withBicycle: false,
                    fastestConnections: true
                ),
                dep: searchDepStop,
                arr: searchArrStop,
                time: searchArrivalTime,
                mode: .arrival,
                pagingReference: nil
            )
			return ApiClient().fetch(
				JourneyResponseIntBahnDe.self,
//				query: Query.queryItems(methods: [
//					.departureStopId(departureStopId: searchDepStop.id),
//					.arrivalStopId(arrivalStopId: searchArrStop.id),
//					.transfersCount(0),
//					.national(icTrains: false),
//					.nationalExpress(iceTrains: false),
//					.regionalExpress(reTrains: false),
//					.taxi(taxi: false),
//					.bus(bus: false),
//					.tram(tram: false),
//					.subway(uBahn: false),
//					.regional(rbTrains: leg.lineViewData.type == .regional),
//					.suburban(sBahn: leg.lineViewData.type == .suburban),
//					.ferry(ferry: false),
//					.arrivalTime(arrivalTime: searchArrivalTime),
//				]),
                query: [],
				type: RequestFabric.Requests.journeys(request)
			)
			.mapError { $0 }
			.asyncFlatMap { dto in
				guard let journeys = dto.journeyDTO().journeys else {
					throw DataError.nilValue(type: "journeyDTO")
				}

				let filtered = journeys.filter { journey in
					let legs = journey.legs
					guard
						legs.count == 1,
						let legToValidate = legs.first,
						searchArrivalPlatform == legToValidate.arrivalPlatform,
						legToValidate.line?.name == leg.lineViewData.name,
						legToValidate.line?.product == leg.lineViewData.type.rawValue,
						let arrTime = ISO8601DateFormatter().date(from: legToValidate.arrival ?? ""),
						searchArrivalTime.timeIntervalSince1970 - arrTime.timeIntervalSince1970 < 3600
					else {
						return false
					}
					return true
				}
				
				guard filtered.count == 1,
					  let resultLeg = filtered.first?.legs.first else {
					throw DataError.nilValue(type: "no journey found")
				}

				let resultTimeContainer = TimeContainer(
					plannedDeparture: stop.time.iso.departure.planned,
					plannedArrival: resultLeg.plannedArrival,
					actualDeparture: stop.time.iso.departure.actual,
					actualArrival: resultLeg.arrival,
					cancelled: nil
				)

				guard resultTimeContainer.date.arrival.actual != nil else {
					throw DataError.validationError(msg: "journey time is nil")
				}
				return Event.didLoad(time: resultTimeContainer.date.arrival)
			}
			.catch { error in
				return Just(Event.didFail(error as! any ChewError)).eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
		}
	}
}

