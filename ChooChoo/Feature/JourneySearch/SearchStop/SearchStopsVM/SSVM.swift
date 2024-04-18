//
//  SearchStopsViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 05.09.23.
//

import Foundation
import Combine
import SwiftUI

class SearchStopsViewModel : ChewViewModelProtocol {
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	@Published private(set) var state : State {
		didSet {
			print("🔎 >> ",state.type ?? "nil","state:",state.status.description)
		}
	}
	
	init(
		_ initialState : State = State(
			previousStops: [],
			stops: [],
			status: .idle
		)
	) {
		state = initialState
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenLoadingStops(),
				Self.whenUpdatingRecentStops()
			]
		)
		.assign(to: \.state, on: self)
		.store(in: &bag)
	}
	deinit {
		bag.removeAll()
	}
	
	func send(event: Event) {
		input.send(event)
	}
	
}

extension SearchStopsViewModel {
	static func sortedStopsByLocationWithDistance(stops : [Stop]) -> [StopWithDistance] {
		var res = [(Stop, Double)]()
		var resOptional = [StopWithDistance]()
		let tmp = stops
		if let location = Model.shared.locationDataManager.locationManager.location {
			res = tmp.map({stop in
				return (stop, location.distance(stop.coordinates.cllocationcoordinates2d))
			})
			res.sort(by: { $0.1 < $1.1 })
			resOptional = res.map({
				StopWithDistance(stop: $0.0, distance: $0.1)
			})
		} else {
			resOptional = tmp.map({ StopWithDistance(stop: $0, distance: nil)})
		}
		return resOptional
	}
}
