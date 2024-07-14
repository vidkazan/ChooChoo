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
	init(appSetttingsVM: AppSettingsViewModel) {
		self.appSetttingsVM = appSetttingsVM
	}
	var body : some View {
		Form {
			journeyAppearence()
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
					appSetttingsVM.send(event: .didRequestToUpdateAppSettings(
						settings: AppSettings(
							debugSettings: appSetttingsVM.state.settings.debugSettings,
							legViewMode: appSetttingsVM.state.settings.legViewMode,
							tips: Set(ChooTip.TipType.allCases)
						)
					))
					Model.shared.sheetVM.send(event: .didRequestHide)
				}, label: {
					Text("Reset tips")
				})
				Button(action: {
					appSetttingsVM.send(event: .didRequestToUpdateAppSettings(settings: AppSettings(
						debugSettings: .init(
							prettyJSON: appSetttingsVM.state.settings.debugSettings.prettyJSON,
							alternativeSearchPage: appSetttingsVM.state.settings.debugSettings.alternativeSearchPage,
							timeSlider: true
						),
						legViewMode: appSetttingsVM.state.settings.legViewMode,
						tips: appSetttingsVM.state.settings.tipsToShow
					)))
					Model.shared.sheetVM.send(event: .didRequestHide)
				}, label: {
					Text("Time slider")
				})
				NavigationLink(destination: {
					LogViewer()
				}, label: {
					Text("Logs")
				})
			})
			#endif
		}
	}
}

extension AppSettingsView {
	@ViewBuilder func journeyAppearence() -> some View {
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
		}, footer: {
			Text("Tap to change route cell appearance", comment: "settingsView: section name")
		})
   }
}

struct LegViewSettingsView : View {
	let mode : AppSettings.LegViewMode
	let mock = Mock.journeys.journeyNeussWolfsburg.decodedData?.journey.journeyViewData(depStop: nil, arrStop: nil, realtimeDataUpdatedAt: 0,settings: .init())
	var body: some View {
		if let mock = mock {
			VStack(alignment: .leading, spacing: 0) {
				LegsView(
					journey: mock,
					mode: mode,
					showLabels: false
				)
				ForEach(mode.description,id:\.hashValue, content: {
					Text(verbatim: "• " + $0)
						.font(.system(.footnote))
						.tint(.secondary)
				})
			}
		}
	}
}

#Preview {
	AppSettingsView(appSetttingsVM: .init(coreDataStore: .preview))
		.environmentObject(ChewViewModel(
			referenceDate: .now, coreDataStore: .preview)
		)
}
