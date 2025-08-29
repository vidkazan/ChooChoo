//
//  MapView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.02.24.
//

import Foundation
import Combine
import CoreLocation
import MapKit
import SwiftUI

class MapPickerViewModel : ChewViewModelProtocol {
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

extension MapPickerViewModel {
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
		case submitting(Stop)
		case loadingStopDetails(Stop,_ send : (MapPickerViewModel.Event)->Void)
		case loadingNearbyStops(_ region : MKCoordinateRegion)
		var description : String {
			switch self {
			case .error(let err):
				return "error \(err.localizedDescription)"
			case .submitting:
				return "submitting"
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
		case didSubmitStop(Stop)
		case didTapStopOnMap(Stop,send : (MapPickerViewModel.Event)->Void)
		case didDragMap(_ region : MKCoordinateRegion)
		
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
			case .didSubmitStop(let stop):
				return "didSelectStop \(stop.name)"
			case .didTapStopOnMap(let stop,_):
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


extension MapPickerViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		Self.log(event, state.status)
		switch state.status {
		case .idle,.error:
			switch event {
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
			case .didSubmitStop(let stop):
				return State(
					data: StateData(
						stops: [],
						selectedStop: nil
					),
					status: .submitting(stop)
				)
			case let .didTapStopOnMap(stop,send):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop,send)
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
			case .didSubmitStop(let stop):
				return State(
					data: StateData(
						stops: [],
						selectedStop: nil
					),
					status: .submitting(stop)
				)
			case let .didTapStopOnMap(stop,send):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop,send)
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
			case .didSubmitStop(let stop):
				return State(
					data: StateData(
						stops: [],
						selectedStop: nil
					),
					status: .submitting(stop)
				)
			case let .didTapStopOnMap(stop,send):
				return State(
					data: StateData(
						stops: state.data.stops,
						selectedStop: stop
					),
					status: .loadingStopDetails(stop,send)
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
		case .submitting:
			return state
		}
	}
}

extension MapPickerViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
	
	static func whenLoadingNearbyStops() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingNearbyStops(let region) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			if region.span.longitudeDelta > 0.02 {
				return Just(Event.didCancelLoading).eraseToAnyPublisher()
			}
			return Self.fetchLocatonsNearby(coords: region.center)
				.mapError{ $0 }
				.asyncFlatMap { res in
					let stops = res.compactMap({$0.stop()})
					return Event.didLoadNearbyStops(stops)
				}
				.catch { error in
					return Just(Event.didFailToLoad(error as? ApiError ?? .generic(description: error.localizedDescription))).eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	static func whenLoadingStopDetails() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case let .loadingStopDetails(stop,send) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			switch stop.type {
			case .location:
                return ChewViewModel.fetchAddressFromLocationIntBahnDE(locaiton: stop.coordinates.cllocationcoordinates2d)
                    .map {
                        guard let stop = $0.first?.stopDTO().stop() else {
                            return Event.didFailToLoad(ApiError.stopNotFound)
                        }
                        return Event.didLoadStopDetails(stop, [])
                    }
                    .catch {
                        return Just(Event.didFailToLoad(ApiError.generic(description: $0.localizedDescription))).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
//				Task {
//					await Self.reverseGeocoding(coords : stop.coordinates,send: send)
//				}
//				return Empty().eraseToAnyPublisher()
			case .pointOfInterest:
				return Just(Event.didCancelLoading).eraseToAnyPublisher()
			case .station,.stop:
                    let products  = {
                        var res = Set<LineType>()
                        state.data.selectedStop?.stopDTO?.products.map {
                            if let lineType = $0.lineType {
                                res.insert(lineType)
                            }
                        }
                        return res
                    }()
                    return Self.fetchStopDepartures(stop:stop,transportTypes: products)
					.map { tripDTOs in
						if let departures = tripDTOs.departures {
							return Event.didLoadStopDetails(stop, departures.compactMap({$0.legViewData(type: .departure)}))
						}
						if let arrivals = tripDTOs.arrivals {
							return Event.didLoadStopDetails(stop, arrivals.compactMap({$0.legViewData(type: .arrival)}))
						}
						return Event.didCancelLoading
					}
					.catch { _ in
						return Just(Event.didCancelLoading).eraseToAnyPublisher()
					}
					.eraseToAnyPublisher()
			}
		}
	}
	
	static func fetchLocatonsNearby(coords : CLLocationCoordinate2D) -> AnyPublisher<[StopDTO],ApiError> {
		return RequestFabric().fetch(
			[StopResponseIntlBahnDe].self,
			query: [
				Query.reiseloesungOrteNearbylong(longitude: String(coords.longitude)).queryItem(),
				Query.reiseloesungOrteNearbylat(latitude: String(coords.latitude)).queryItem()
			],
			type: RequestFabric.Requests.locationsNearby
		)
        .map{$0.map{$0.stopDTO()}}
		.eraseToAnyPublisher()
	}
	
    static func fetchStopDepartures(stop : Stop, transportTypes : Set<LineType>) -> AnyPublisher<StopTripsDTO,ApiError> {
        let queryTransport : [URLQueryItem] = transportTypes.compactMap {
            if let tranport = StopResponseIntlBahnDe.EndpointProducts(
                rawValue: $0
                    .intbahndeEndpointProducts()?
                    .rawValue ?? ""
            ) {
                return Query.reiseloesungAbfahrtenVerkehrsmittel(transport: tranport).queryItem()
            }
            return nil
        }
		return RequestFabric().fetch(
            StopDeparturesResponse.self,
			query: [
                Query.reiseloesungAbfahrtenMitVias(false).queryItem(),
                Query.reiseloesungAbfahrtenOrtId(stop.id).queryItem(),
                Query.reiseloesungAbfahrtenZeit(Self.formatTime(from: Date.now)).queryItem(),
                Query.reiseloesungAbfahrtenDatum(Self.formatDate(from: Date.now)).queryItem(),
			] + queryTransport,
			type: RequestFabric.Requests.stopDepartures
		)
        .map {
            print($0)
            return $0.stopTripDTO()
        }
		.eraseToAnyPublisher()
	}
	
//	private static func reverseGeocoding(coords : Coordinate,send : (MapPickerViewModel.Event)->Void) async {
//		if let res = await Model.shared.locationDataManager.reverseGeocoding(coords: coords) {
//			let stop = Stop(
//				coordinates: coords,
//				type: .location,
//				stopDTO: StopDTO(name: res, products: nil)
//			)
//			send(Event.didLoadStopDetails(stop,[]))
//		} else {
//			let stop = Stop(
//				coordinates: coords,
//				type: .location,
//				stopDTO: StopDTO(name: String(coords.latitude) + " " + String(coords.longitude), products: nil)
//			)
//			send(Event.didLoadStopDetails(stop,[]))
//		}
//	}
}

extension MapPickerViewModel {
	static func addStopAnnotation(id: String?,lineType : LineType, stopName : String,coords : CLLocationCoordinate2D, mapView : MKMapView,stopOverType : StopOverType?){
		switch lineType {
		case .nationalExpress,.national,.regionalExpress:
			let anno : IceStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .regional:
			let anno : ReStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .suburban:
			let anno : SStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .bus:
			let anno : BusStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .replacementBus:
			let anno : ReplacementBusStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .ferry:
			let anno : ShipStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .subway:
			let anno : UStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .tram:
			let anno : TramStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .taxi:
			let anno : TaxiStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .transfer:
			let anno : TransferStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		case .foot:
			let anno : FootStopAnnotation = lineType.stopAnnotation(
				id: id,
				name: stopName,
				coords: coords, stopOverType: stopOverType
			)
			mapView.addAnnotation(anno)
		}
	}
}

extension MapPickerViewModel {
	static func mapView(
		_ mapView: MKMapView,
		viewFor annotation: MKAnnotation
	) -> MKAnnotationView? {
		if annotation.isKind(of: StopAnnotation.self) {
			if let annotation = annotation as? BusStopAnnotation {
				let res : BusStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation, mapView: mapView)
				return res
			} else if let annotation = annotation as? IceStopAnnotation {
				let res : IceStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? ReStopAnnotation {
				let res : ReStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? SStopAnnotation {
				let res : SStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? UStopAnnotation {
				let res : UStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? TramStopAnnotation {
				let res : TramStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? ShipStopAnnotation {
				let res : ShipStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? TaxiStopAnnotation {
				let res : TaxiStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? FootStopAnnotation {
				let res : FootStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			} else if let annotation = annotation as? TransferStopAnnotation {
				let res : TransferStopAnnotationView? = Self.setupStopAnnotationViewGeneric(for: annotation,mapView: mapView)
				return res
			}
		}
		return nil
	}
	
	static func setupStopAnnotationViewGeneric<T: MKAnnotation, U: ChewAnnotationView>(
		for annotation: T,
		mapView: MKMapView
	) -> U? {
		if let annotationView = mapView.dequeueReusableAnnotationView(
			withIdentifier: NSStringFromClass(T.self),
			for: annotation
		) as? U,
		let anno = annotation as? StopAnnotation {
			Self.setupAnnotationView(
				view: annotationView,
				annotation: anno
			)
			return annotationView
		}
		return nil
	}
	
	static func setupAnnotationView(view: ChewAnnotationView, annotation : StopAnnotation){
		view.setupUI(annotation.type.iconBig)
		let strokeTextAttributes: [NSAttributedString.Key : Any] = [
			.strokeColor : UIColor.systemBackground,
			.strokeWidth : -2.0,
			.font : UIFont.boldSystemFont(ofSize: 12)
		]
		view.titleLabel?.attributedText = NSAttributedString(string: annotation.name, attributes: strokeTextAttributes)
	}
}

extension StopDeparturesResponse {
    func stopTripDTO() -> StopTripsDTO {
        let deps : [StopTripDTO] = self.departure.map {
            #warning("hardcoded nils!")
            let container = TimeContainer(
                plannedDeparture: DateParcer
                    .convertDateFormatTo(
                        date: $0.ezZeit ?? $0.zeit,
                        inputFormat: JourneyResponseIntBahnDe.formatDateAndTime,
                        outputFormat: DateParcer.defaultFormat
                    ),
                plannedArrival: nil,
                actualDeparture: DateParcer
                    .convertDateFormatTo(
                        date: $0.zeit,
                        inputFormat: JourneyResponseIntBahnDe.formatDateAndTime,
                        outputFormat: DateParcer.defaultFormat
                    ),
                actualArrival: nil,
                cancelled: nil
            )
            return StopTripDTO(
                stop: nil,
                origin: nil,
                destination: StopDTO(
                    name: $0.terminus ?? "",
                    products: nil
                ),
                line: $0.verkehrmittel?.lineDTO(),
                remarks: $0.meldungen?.compactMap{$0.remark()},
                when: container.iso.departure.actual,
                plannedWhen: container.iso.departure.planned,
                delay: container.departureStatus.value,
                tripId: $0.journeyId,
                direction: $0.terminus,
                currentLocation: nil,
                platform: $0.ezGleis ?? $0.gleis ,
                plannedPlatform: $0.gleis
            )
        }
        return StopTripsDTO(
            departures: deps,
            arrivals: nil
        )
    }
}

extension MapPickerViewModel {
    private static func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    private static func formatDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
