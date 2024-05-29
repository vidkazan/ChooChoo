//
//  saveSettings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.01.24.
//

import Foundation
import SwiftUI

extension SettingsView {
	func saveSettings(){
		Task {
			let newSettings = JourneySettings(settings: currentSettings)
			if newSettings != oldSettings {
				chewViewModel.send(event: .didUpdateSearchData(journeySettings: newSettings))
				Model.shared.coreDataStore.updateJounreySettings(
					newSettings: newSettings
				)
			}
		}
	}
}
