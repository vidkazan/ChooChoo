//
//  ChooTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 24.04.24.
//

import Foundation
import SwiftUI
import ChooViews

extension ChooTip {
	struct SunEventsTipView : View {
		let mode : AppSettings.LegViewMode
		let mock = Mock
			.journeys
			.journeySyltWien
			.decodedData?
			.journey
			.journeyViewData(
				depStop: nil,
				arrStop: nil,
				realtimeDataUpdatedAt: 0,
				settings: .init()
			)
		var body: some View {
			if let mock = mock {
				VStack(alignment: .leading) {
					Text("**Yellow** color shows **daylight**,",comment: "SunEventsTipView")
					Text("**Blue** color - **moonlight**",comment: "SunEventsTipView")
					LegsView(
						journey: mock,
						mode: mode,
						showLabels: false,
						showLegs: false
					)
					.overlay {
						HStack {
							ChooSFSymbols.sunMaxFill.view.chewTextSize(.medium)
								.padding(.leading,20)
							Spacer()
							ChooSFSymbols.moonStars.view.chewTextSize(.medium)
							Spacer()
							ChooSFSymbols.sunMaxFill.view.chewTextSize(.medium)
								.padding(.trailing,10)
						}
						.foregroundStyle(.primary)
					}
				}
				.padding(10)
				.badgeBackgroundStyle(.secondary)
				.padding(10)
			}
		}
	}
}
