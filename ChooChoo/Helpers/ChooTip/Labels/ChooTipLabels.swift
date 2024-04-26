//
//  ChooTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 24.04.24.
//

import Foundation
import SwiftUI

extension ChooTip {
	struct Labels {}
}


extension ChooTip.Labels {
	struct JourneySettingsFilterDisclaimer : View {
		var body: some View {
			HStack {
				Label(
					title: {
						Text(
							"Current settings could reduce your search results",
							comment: "settingsView: warning"
						)
						.foregroundStyle(.secondary)
						.font(.system(.footnote))
					},
					icon: {
						JourneySettings.IconBadge.redDot.view
					}
				)
				Spacer()
				Button(action: {
					Model.shared.appSettingsVM.send(event: .didShowTip(tip: .journeySettingsFilterDisclaimer))
				}, label: {
					Image(.xmarkCircle)
						.chewTextSize(.big)
						.tint(.secondary)
				})
			}
		}
	}
}

extension ChooTip.Labels {
	struct HowToFollowJourneyView : View {
		@State var isPressed : Bool = false
		let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
		var body: some View {
			HStack {
				Spacer()
				Text("Journey Details",
					 comment: "info sheet: follow journey button: view name"
				)
				.chewTextSize(.big)
				Spacer()
				Group {
					ChooSFSymbols.bookmark.view
						.symbolVariant(isPressed ? .fill : .none )
					ChooSFSymbols.arrowClockwise.view
				}
				.foregroundStyle(.blue)
				.frame(width: 15,height: 15)
				.padding(5)
			}
			.onReceive(timer, perform: { _ in
				withAnimation {
					isPressed.toggle()
				}
			})
			.padding(10)
			.background(.regularMaterial)
			.clipShape(.rect(cornerRadius: 10, style: .continuous))
			.padding(10)
		}
	}
}
