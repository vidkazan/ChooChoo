//
//  AppSettingsVM.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.03.24.
//

import Foundation
import Combine


class AppSettingsViewModel : ObservableObject, Identifiable {
	@Published private(set) var state : State {
		didSet { print("🚂⚙️ >> state:",state.status,state.settings) }
	}
	private var bag = Set<AnyCancellable>()
	private let input = PassthroughSubject<Event,Never>()
	
	
	init(settings : AppSettings = AppSettings(),status : Status = .idle) {
		self.state = State(settings: settings,status: status)
		Publishers.system(
			initial: State(settings: settings,status: status),
			reduce: Self.reduce,
			scheduler: RunLoop.main,
			feedbacks: [
				Self.userInput(input: input.eraseToAnyPublisher()),
				Self.whenUpdatedSettings()
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

extension AppSettingsViewModel  {
	struct State : Equatable  {
		let status : Status
		let settings : AppSettings

		init(settings: AppSettings,status : Status) {
			self.settings = settings
			self.status = status
		}
	}
	
	enum Status : Equatable {
		static func == (lhs: AppSettingsViewModel.Status, rhs: AppSettingsViewModel.Status) -> Bool {
			return lhs.description == rhs.description
		}
		
		case updating
		case idle
		
		
		var description : String {
			switch self {
			case .idle:
				return "idle"
			case .updating:
				return "updating"
			}
		}
	}
	enum Event {
		case didRequestToLoadInitialData(settings : AppSettings)
		case didShowTip(tip : AppSettings.ChooTipType)
		case didRequestToChangeLegViewMode(mode : AppSettings.LegViewMode)
		case didUpdateData
		var description : String {
			switch self {
			case .didUpdateData:
				return "didUpdateData"
			case .didRequestToLoadInitialData:
				return "didRequestToLoadInitialData"
			case .didShowTip:
				return "didShowTip"
			case .didRequestToChangeLegViewMode:
				return "didRequestToChangeLegViewMode"
			}
		}
	}
}


extension AppSettingsViewModel {
	static func reduce(_ state: State, _ event: Event) -> State {
		print("🚂⚙️ >> ",event.description,"state:",state.status,state.settings)
		switch state.status {
			case .idle:
			switch event {
			case .didRequestToLoadInitialData(let settings):
				return State(settings: settings, status: .idle)
			case .didShowTip(let tip):
				var tips = state.settings.tipsToShow
				tips.remove(tip)
				return State(settings: AppSettings(
					oldSettings: state.settings,
					tips: tips
				),status: .updating)
			case .didRequestToChangeLegViewMode(let mode):
				return State(settings: AppSettings(
					oldSettings: state.settings,
					legViewMode: mode
				),status: .updating)
			case .didUpdateData:
				return state
			}
			case .updating:
			switch event {
			case .didRequestToLoadInitialData(let settings):
				return State(settings: settings, status: .idle)
			case .didShowTip(let tip):
				var tips = state.settings.tipsToShow
				tips.remove(tip)
				return State(settings: AppSettings(
					oldSettings: state.settings,
					tips: tips
				),status: .updating)
			case .didRequestToChangeLegViewMode(let mode):
				return State(settings: AppSettings(
					oldSettings: state.settings,
					legViewMode: mode
				),status: .updating)
			case .didUpdateData:
				return State(settings: state.settings, status: .idle)
			}
		}
	}
}

extension AppSettingsViewModel {
	static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
		Feedback { _ in
			return input
		}
	}
		
	static func whenUpdatedSettings() -> Feedback<State, Event> {
		Feedback { (state: State) -> AnyPublisher<Event, Never> in
			guard case .updating = state.status else {
				return Empty().eraseToAnyPublisher()
			}
			Model.shared.coreDataStore.updateAppSettings(
				newSettings: state.settings
			)
			return Just(Event.didUpdateData).eraseToAnyPublisher()
		}
	}
}

