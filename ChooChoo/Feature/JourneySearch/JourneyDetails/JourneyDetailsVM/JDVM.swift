//
//  JourneyDetailsViewModel.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//


import Foundation
import Combine
import CoreData

final class JourneyDetailsViewModel : ChewViewModelProtocol {
	
	@Published private(set) var state : State {
		didSet { print("🚂 > state:",state.status.description) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	init (
		followId: Int64,
		data: JourneyViewData,
		depStop : Stop,
		arrStop : Stop,
		chewVM : ChewViewModel?,
		initialStatus : Status = .loadedJourneyData
	) {
//		print("💾 JDVM \(self.id.uuidString.suffix(4)) init")
		state = State(
			followId: followId,
			chewVM : chewVM,
			depStop: depStop,
			arrStop: arrStop,
			viewData: data,
			status: initialStatus
		)
		
		Publishers.system(
			initial: state,
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenLoadingJourneyByRefreshToken(),
				Self.whenChangingSubscribitionType(),
				Self.whenLoadingIfNeeded(),
			]
		)
		.weakAssign(to: \.state, on: self)
		.store(in: &bag)
	}
	deinit {
//		print("💾🗑️ JDVM \(self.id.uuidString.suffix(4)) deinit")
		bag.removeAll()
	}
	func send(event: Event) {
		input.send(event)
	}
}
