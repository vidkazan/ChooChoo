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
				Model.shared.locationDataManager.requestLocation()
				guard let coords = Model.shared.locationDataManager.location?.coordinate else {
					Model.shared.topBarAlertVM.send(event: .didRequestShow(.userLocationError))
					return Just(Event.didFailToLoadLocationData).eraseToAnyPublisher()
				}
				Task {
					await Self.reverseGeocoding(
						coords : Coordinate(coords),
						send:send
					)
				}
				return Empty().eraseToAnyPublisher()
			@unknown default:
				Model.shared.topBarAlertVM.send(event: .didRequestShow(.userLocationError))
				return Just(Event.didFailToLoadLocationData).eraseToAnyPublisher()
			}
		}
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
			send(Event.didReceiveLocationData(stop))
		}
	}
}

