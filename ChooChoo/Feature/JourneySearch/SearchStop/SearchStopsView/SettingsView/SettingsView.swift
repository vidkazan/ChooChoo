//
//  SettingsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
	@EnvironmentObject  var chewViewModel : ChewViewModel
	@ObservedObject var appSettingsVM : AppSettingsViewModel = Model.shared.appSettingsVM
	@ObservedObject var currentSettings : JourneySettingsClass
	let closeSheet : ()->Void
	let oldSettings : JourneySettings
	
	init(settings : JourneySettings, closeSheet : @escaping ()->Void) {
		self.oldSettings = settings
		self.currentSettings = JourneySettingsClass(settings: settings)
		self.closeSheet = closeSheet
	}
	
	var body: some View {
		VStack(spacing: 0) {
			if appSettingsVM.state.settings.showTip(
				tip: .journeySettingsFilterDisclaimer
			) {
				filterDisclaimer()
					.padding(10)
					.badgeBackgroundStyle(.secondary)
					.padding(10)

			}
			Form {
				transportTypes
				if currentSettings.transportMode == .custom {
					segments
				}
				connections
				if case .time = currentSettings.transferTime {
					transferSegment
				}
				Section {
					Picker(
						selection: Binding<JourneySettings.Accessiblity>(
							get:{
								currentSettings.accessiblity
							},
							set:{
								currentSettings.accessiblity = $0
							}
						),
						content: {
							ForEach(JourneySettings.Accessiblity.allCases,id: \.hashValue, content: { elem in
								Text(elem.string)
									.tag(elem)
							})
						},
						label: {
							Label(
								title: { Text("Accesibility", comment: "Settings") },
								icon: { Image(systemName: "figure.roll") }
							)
						}
					)
					Toggle(
						isOn: Binding<Bool>(
							get:{
								currentSettings.withBicycle
							},
							set:{
								currentSettings.withBicycle = $0
							}
						),
						label: {
							Label(
								title: { Text("With bicycle", comment: "Settings") },
								icon: { Image(systemName: "bicycle") }
							)
						})
				}
				reset()
			}
			.animation(.easeInOut, value: currentSettings.isDefault())
			.animation(.easeInOut, value: appSettingsVM.state.settings)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing, content: {
					Button(action: {
						saveSettings()
						closeSheet()
					}, label: {
						Text("Save", comment: "settingsView: save button")
							.chewTextSize(.big)
							.frame(maxWidth: .infinity,minHeight: 35,maxHeight: 43)
					})
				}
			)}
		}
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

extension SettingsView {
	@ViewBuilder func filterDisclaimer() -> some View {
		if !currentSettings.isDefault() {
			Section {
				AppSettings.ChooTip.journeySettingsFilterDisclaimer.tipLabel
			}
		}
	}
	
	@ViewBuilder func reset() -> some View {
		Section {
			Button(role: .destructive, action: {
				Model.shared.alertViewModel.send(
					event: .didRequestShow(.destructive(
						destructiveAction: {
							chewViewModel.send(
								event: .didUpdateSearchData(
									journeySettings: JourneySettings()
								)
							)
							closeSheet()
						},
						description: NSLocalizedString(
							"Reset settings?",
							comment: "alert: description"
						),
						actionDescription: NSLocalizedString(
							"Reset",
							comment: "alert: actionDescription"
						),
						id: UUID()
					))
				)
			}, label: {
				Text("Reset settings",comment: "settingsView: button name")
			})
		}
	}
}

#if DEBUG
struct SettingsPreview: PreviewProvider {
	static var previews: some View {
		SettingsView(
			settings: .init(),
			closeSheet: {}
		)
			.environmentObject(ChewViewModel(referenceDate: .now))
	}
}
#endif
