//
//  +sideEffect.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Combine
import Foundation
import CoreLocation

extension ChewViewModel {
	static func whenLoadingUserLocation() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .loadingLocation(let send) = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			switch Model.shared.locationDataManager.authorizationStatus {
			case .notDetermined,.restricted,.denied,.none:
				Model.shared.topBarAlertVM.send(event: .didRequestShow(.userLocationError))
				return Just(Event.didFailToLoadLocationData).eraseToAnyPublisher()
			case .authorizedAlways,.authorizedWhenInUse:
                
				if let coords = Model.shared.locationDataManager.location?.coordinate {
                    return Self.fetchAddressFromLocationIntBahnDE(locaiton: coords)
                    .map { response in
                        if let data = response.first?.stopDTO().stop() {
                            return Event.didReceiveLocationData(data)
                        }
                        return Event.didFailToLoadLocationData
                    }
                    .catch { _ in
                        return Just(Event.didFailToLoadLocationData).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
//					Task {
//						await Self.reverseGeocoding(
//							coords : Coordinate(coords),
//							send:send
//						)
//					}
				} else {
					Self.warning(state.status, "whenLoadingUserLocation: coords nil -> bypassing geocoding")
				}
				return Empty().eraseToAnyPublisher()
			@unknown default:
				Model.shared.topBarAlertVM.send(event: .didRequestShow(.userLocationError))
				return Just(Event.didFailToLoadLocationData).eraseToAnyPublisher()
			}
		}
	}
	
    static func fetchAddressFromLocationIntBahnDE(locaiton : CLLocationCoordinate2D) -> AnyPublisher<[StopResponseIntlBahnDe],ApiError> {
        return ApiService().fetch(
            [StopResponseIntlBahnDe].self,
            query: [
                Query.reiseloesungOrteNearbylat(latitude: String(locaiton.latitude)).queryItem(),
                Query.reiseloesungOrteNearbylong(longitude: String(locaiton.longitude)).queryItem()
            ],
            type: ApiService.Requests.addresslookup
        )
        .eraseToAnyPublisher()
    }
    
	private static func reverseGeocoding(coords : Coordinate,send : (ChewViewModel.Event)->Void) async {
		if let res = await Model.shared.locationDataManager.reverseGeocoding(coords: coords) {
			let stop = Stop(
				coordinates: coords,
				type: .location,
				stopDTO: StopDTO(name: res, products: nil)
			)
			send(Event.didReceiveLocationData(stop))
		} else {
			let stop = Stop(
				coordinates: coords,
				type: .location,
				stopDTO: StopDTO(name: String(coords.latitude) + " " + String(coords.longitude),products: nil)
			)
			Self.warning(Status.loadingLocation(send: {_ in}), "whenLoadingUserLocation: geocoding failed, putting coordinates")
			send(Event.didReceiveLocationData(stop))
		}
	}
}

