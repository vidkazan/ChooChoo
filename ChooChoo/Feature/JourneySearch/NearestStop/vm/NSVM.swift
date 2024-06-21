//
//  NearestStopViewModel.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 19.04.24.
//

import Foundation
import Combine
import CoreLocation
import MapKit
import SwiftUI

class NearestStopViewModel : ChewViewModelProtocol {
	@Published private(set) var state : State {
		didSet { Self.log(state.status) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	
	init(_ initaialStatus : Status) {
		self.state = State(
			data: StateData(
				stops: [],
				selectedStop: nil
			),
			status: initaialStatus
		)
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenLoadingNearbyStops(),
				Self.whenLoadingStopDetails()
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

extension NearestStopViewModel {
	struct State {
		let data : StateData
		let status : Status
	}
	
	struct StateData {
		let stops : [Stop]
		let selectedStop : Stop?
		let selectedStopTrips : [LegViewData]?
		
		init(stops: [Stop], selectedStop: Stop?) {
			self.stops = stops
			self.selectedStop = selectedStop
			self.selectedStopTrips = nil
		}
		init(stops: [Stop], selectedStop: Stop?,trips : [LegViewData]?) {
			self.stops = stops
			self.selectedStop = selectedStop
			self.selectedStopTrips = trips
		}
	}
	
	enum Status :  ChewStatus {
		case idle
		case error(any ChewError)
		case loadingStopDetails(Stop)
		case loadingNearbyStops(_ coordinates : CLLocation)
		var description : String {
			switch self {
			case .error(let err):
				return "error \(err.localizedDescription)"
			case .idle:
				return "idle"
			case .loadingStopDetails:
				return "loadingStopDetails"
			case .loadingNearbyStops:
				return "loadingNearbyStops"
			}
		}
	}
	
	enum Event : ChewEvent {
		case didDeselectStop
		case didTapStopOnMap(Stop)
		case didRequestReloadStopDepartures(Stop)
		case didDragMap(_ coordinates : CLLocation)
		case didLoadStopDetails(Stop,_ stopTrips : [LegViewData])
		case didLoadNearbyStops([Stop])
		case didCancelLoading
		case didFailToLoad(any ChewError)
		var description : String {
			switch self {
			case .didDeselectStop:
				return "didDeselectStop"
			case .didFailToLoad(let err):
				return "didFailToLoad \(err.localizedDescription)"
			case .didCancelLoading:
				return "didCancelLoading"
			case .didTapStopOnMap(let stop):
				return "didTapStopOnMaps \(stop.name)"
			case .didRequestReloadStopDepartures(let stop):
				return "didTapStopOnMaps \(stop.name)"
			case .didDragMap:
				return "didDragMap"
			case .didLoadStopDetails(_,_):
				return "didLoadStopDetails"
			case .didLoadNearbyStops(_):
				return "didLoadNearbyStops"
			}
		}
	}
}


extension NearestStopViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.status)
		switch state.status {
		case .idle,.error:
			switch event {
			case .didRequestReloadStopDepartures(let stop):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: state.data.selectedStop
					),
					status: .loadingStopDetails(
						state.data.selectedStop ?? stop
					)
				)
			case .didFailToLoad(let err):
				return State(data: state.data, status: .error(err))
			case .didCancelLoading:
				return state
			case .didDeselectStop:
				return State(
					data: .init(
						stops: state.data.stops,
						selectedStop: nil
					),
					status: .idle
				)
			case let .didTapStopOnMap(stop):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop)
				)
			case .didDragMap(let coords):
				return State(
					data: state.data,
					status: .loadingNearbyStops(coords)
				)
			case let .didLoadStopDetails(stop, trips):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop.coordinates == state.data.selectedStop?.coordinates ? stop : state.data.selectedStop,
						trips: trips
					),
					status: .idle
				)
			case .didLoadNearbyStops(let stops):
				return State(
					data: StateData(
						stops: stops,
						selectedStop: state.data.selectedStop,
						trips: state.data.selectedStopTrips
					),
					status: .idle
				)
			}
		case .loadingStopDetails:
			switch event {
			case .didRequestReloadStopDepartures:
				return state
			case .didDeselectStop:
				return State(
					data: .init(
						stops: state.data.stops,
						selectedStop: nil
					),
					status: .idle
				)
			case .didFailToLoad(let err):
				return State(data: state.data, status: .error(err))
			case .didCancelLoading:
				return State(data: state.data, status: .idle)
			case let .didTapStopOnMap(stop):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop)
				)
			case .didDragMap(let coords):
				return State(
					data: state.data,
					status: .loadingNearbyStops(coords)
				)
			case let .didLoadStopDetails(stop, trips):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop.coordinates == state.data.selectedStop?.coordinates ? stop : state.data.selectedStop,
						trips: trips
					),
					status: .idle
				)
			case .didLoadNearbyStops(let stops):
				return State(
					data: StateData(
						stops: stops,
						selectedStop: state.data.selectedStop,
						trips: state.data.selectedStopTrips
					),
					status: .idle
				)
			}
		case .loadingNearbyStops:
			switch event {
			case .didRequestReloadStopDepartures:
				return state
			case .didDeselectStop:
				return State(
					data: .init(
						stops: state.data.stops,
						selectedStop: nil
					),
					status: .idle
				)
			case .didFailToLoad(let err):
				return State(data: state.data, status: .error(err))
			case .didCancelLoading:
				return State(data: state.data, status: .idle)
			case let .didTapStopOnMap(stop):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop)
				)
			case .didDragMap(let coords):
				return State(
					data: state.data,
					status: .loadingNearbyStops(coords)
				)
			case let .didLoadStopDetails(stop, trips):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop.coordinates == state.data.selectedStop?.coordinates ? stop : state.data.selectedStop,
						trips: trips
					),
					status: .idle
				)
			case .didLoadNearbyStops(let stops):
				return State(
					data: StateData(
						stops: stops,
						selectedStop: state.data.selectedStop,
						trips: state.data.selectedStopTrips
					),
					status: .idle
				)
			}
		}
	}
}

extension NearestStopViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	
	static func whenLoadingNearbyStops() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingNearbyStops(let coordinates) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			return Self.fetchLocatonsNearby(coords: coordinates)
				.mapError{ $0 }
				.asyncFlatMap { res in
					let stops : [Stop] = res.compactMap{
						$0.stop()
					}
					return Event.didLoadNearbyStops(stops)
				}
				.catch { error in
					return Just(
						Event.didFailToLoad(error as? ApiError ?? .generic(description: error.localizedDescription))
					).eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	static func whenLoadingStopDetails() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .loadingStopDetails(stop) = state.status else {
					return Empty().eraseToAnyPublisher()
			}
			switch stop.type {
			case .station,.stop:
				return Self.fetchStopDepartures(stop:stop)
					.mapError{ $0 }
					.asyncFlatMap { tripDTOs in
						if let departures = tripDTOs.departures {
							return Event.didLoadStopDetails(stop, departures.compactMap({$0.legViewData(type: .departure)}))
						}
						if let arrivals = tripDTOs.arrivals {
							return Event.didLoadStopDetails(stop, arrivals.compactMap({$0.legViewData(type: .arrival)}))
						}
						return Event.didCancelLoading
					}
					.catch { err in
						return Just(
							Event.didFailToLoad(err as? ApiError ?? .generic(description: err.localizedDescription))
						).eraseToAnyPublisher()
					}
					.eraseToAnyPublisher()
			default:
				return Just(Event.didCancelLoading).eraseToAnyPublisher()
			}
		}
	}
	
	static func fetchLocatonsNearby(coords : CLLocation) -> AnyPublisher<[StopDTO],ApiError> {
		let predictedCoords = Self.calculateNextCoordinates(loc: coords, time: 7.5)
		return ChooNetworking().fetch(
			[StopDTO].self,
			query: [
				Query.longitude(longitude: String(predictedCoords.longitude)).queryItem(),
				Query.latitude(latitude: String(predictedCoords.latitude)).queryItem()
			],
			type: ChooNetworking.Requests.locationsNearby(coords: coords.coordinate)
		)
		.eraseToAnyPublisher()
	}
	
	static func fetchStopDepartures(stop : Stop) -> AnyPublisher<StopTripsDTO,ApiError> {
		return ChooNetworking().fetch(
			StopTripsDTO.self,
			query: [
				Query.duration(minutes: 60).queryItem(),
				Query.results(max: 20).queryItem()
			],
			type: ChooNetworking.Requests.stopDepartures(stopId: stop.id)
		)
		.eraseToAnyPublisher()
	}
	
	static private func calculateNextCoordinates(loc : CLLocation, time : Double?) -> CLLocationCoordinate2D {
		let d = loc.speed * (time ?? 0)
		let brng = Model.shared.locationDataManager.heading?.trueHeading ?? loc.course
		let R = 6371000.0
		let φ1 = loc.coordinate.latitude.degreesToRadians
		let λ1 = loc.coordinate.longitude.degreesToRadians
		let φ2 = asin(sin(φ1) * cos(d / R) + cos(φ1) * sin(d / R) * cos(brng))
		let λ2 = λ1 + atan2(sin(brng) * sin(d / R) * cos(φ1),
							cos(d / R) - sin(φ1) * sin(φ2))
		
		return CLLocationCoordinate2D(
			latitude: φ2.radiansToDegrees,
			longitude: λ2.radiansToDegrees
		)
	}
}
