//
//  AppSettingsView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.03.24.
//

import Foundation
import SwiftUI


struct AppSettingsView: View {
	@ObservedObject var appSetttingsVM : AppSettingsViewModel
	init(appSetttingsVM: AppSettingsViewModel = Model.shared.appSettingsVM) {
		self.appSetttingsVM = appSetttingsVM
	}
	var body : some View {
		Form {
			Section(content: {
				Button(action: {
					appSetttingsVM.send(
						event: .didRequestToChangeLegViewMode(
							mode: appSetttingsVM.state.settings.legViewMode.next()
						)
					)
				}, label: {
					LegViewSettingsView(
						mode: appSetttingsVM.state.settings.legViewMode
					)
				})
			}, header: {
				Text("Journey appearance", comment: "settingsView: section name")
			})
			Section {
				Button(action: {
					UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,options: [:], completionHandler: nil)
				}, label: {
					Text("App system settings",comment: "AppSettingsView")
				})
			}
			#if DEBUG
			Section("Debug", content: {
				Button(action: {
					appSetttingsVM.send(event: .didRequestToLoadInitialData(
						settings: AppSettings(
							debugSettings: appSetttingsVM.state.settings.debugSettings,
							legViewMode: appSetttingsVM.state.settings.legViewMode,
							tips: Set(AppSettings.ChooTipType.allCases)
						)
					))
				}, label: {
					Text("Reset tips")
				})
			})
			#endif
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(
			Text("App Settings", comment: "navigationBarTitle")
		)
	}
}

#Preview {
	AppSettingsView(appSetttingsVM: .init())
}
