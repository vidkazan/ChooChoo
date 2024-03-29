//
//  SettingsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

extension SettingsView {
	var connections : some View {
		Section(content: {
			Picker(
				selection:
					Binding<Bool>(
						get: {
							currentSettings.transferTime != .direct
						},
						set: {
							switch $0 {
							case true:
								currentSettings.transferTime = .time(minutes: .zero)
							case false:
								currentSettings.transferTime = .direct
							}
						}
					),
				content: {
					Label(
						title: {
							Text("Direct", comment : "SettingsView: connections: picker option")
						},
						icon: {
							Image(systemName: "arrow.up.right")
						}
					)
					.tag(false)
					Label(
						title: {
							Text("With transfers", comment : "SettingsView: connections: picker option")
						},
						icon: {
							Image(.arrowLeftArrowRight)
						}
					)
					.tag(true)
				}, label: {
				})
			.pickerStyle(.inline)
		}, header: {
			Text("Connections",comment: "SettingsView: connections: section header")
		})
	}
}

extension SettingsView {
	var transferSegment : some View {
		Section(content: {
			Picker(
				selection:
					Binding<JourneySettings.TransferDurationCases>(
						get: {
							switch currentSettings.transferTime {
							case .direct:
								return .zero
							case .time(let minutes):
								return minutes
							}
						},
						set: {
							switch currentSettings.transferTime {
							case .direct:
								currentSettings.transferTime = .direct
							case .time:
								currentSettings.transferTime = .time(minutes: $0)
							}
						}
					),
				content: {
					ForEach(JourneySettings.TransferDurationCases.allCases,id: \.rawValue) { val in
						Text(verbatim: val.string)
//						Text(
//							"\(val.rawValue) min ",
//							comment: "SettingsView: transferSegment: transfer duration"
//						)
						.tag(val)
					}
				}, label: {
					Label(
						title: {
							Text("Duration", comment : "SettingsView: transferSegment: picker name")
						},
						icon: {
							Image(systemName: "clock.arrow.circlepath")
						}
					)
				}
			)
			Picker(
				selection:
					Binding<JourneySettings.TransferCountCases>(
						get: {
							currentSettings.transferCount
						},
						set: {
							currentSettings.transferCount = $0
						}
					),
				content: {
					ForEach(JourneySettings.TransferCountCases.allCases,id: \.rawValue) { val in
						Text(verbatim: val.string)
							.tag(val)
					}
				}, label: {
					Label(
						title: {
							Text("Count", comment : "SettingsView: transferSegment: picker name")
						},
						icon: {
							Image(.arrowLeftArrowRight)
						}
					)
				}
			)
		}, header: {
			Text("Transfer",comment: "SettingsView: transferSegment: section header")
		})
	}
}

//extension SettingsView {
//	var debug : some View {
//		Section(content: {
//			Toggle(
//				isOn: Binding(
//					get: { alternativeSearchPage },
//					set: { _ in alternativeSearchPage.toggle()}
//				),
//				label: {
//					Text("Show alternative search page",comment: "SettingsView: debug: toggle")
//				}
//			)
//		}, header: {
//			Text("Debug options",comment: "SettingsView: debug: section header")
//		})
//	}
//}
