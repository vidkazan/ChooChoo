//
//  AppVM.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import CoreData

final class ChewViewModel : ChewViewModelProtocol {
	let referenceDate : ChewDate
	
	@Published private(set) var state : State {
		didSet {
			Self.log(state.status)
		}
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	init (
		initialState : State = State(),
		referenceDate : ChewDate = .now,
		coreDataStore : CoreDataStore
	) {
		self.state = initialState	
		self.referenceDate = referenceDate
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenIdleCheckForSufficientDataForJourneyRequest(),
				Self.whenLoadingUserLocation(),
				Self.whenLoadingInitialData(coreDataStore: coreDataStore),
				Self.whenEditingStops()
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
