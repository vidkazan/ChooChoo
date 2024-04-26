//
//  SunEventsTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI

extension ChooTip.Labels {
	struct SunEventsTip: View {
		let onClose : () -> ()
		let journey : JourneyViewData?
		var body: some View {
			Button(action: {
				Model.shared.sheetVM.send(
					event: .didRequestShow(
						.tip(
							.sunEvents(
								onClose: onClose,
								journey: journey
							)
						)
					)
				)
			}, label : {
				HStack {
					Label(
						title: {
							Text("What does this colorful line mean?", comment: "jlv: header info: sunevents")
								.chewTextSize(.medium)
						},
						icon: {
							ChooSFSymbols.infoCircle.view
								.padding(.leading,10)
						}
					)
					.tint(.primary)
					Spacer()
					Button(action: {
						onClose()
					}, label: {
						ChooSFSymbols.xmarkCircle.view
							.chewTextSize(.big)
							.tint(.gray)
					})
					.frame(width: 40, height: 40)
				}
				.padding(5)
				.frame(height: 40)
				.background {
					LinearGradient(
						stops: journey?
							.sunEventsGradientStops
							.map {
								.init(
									color: $0.color.opacity(0.7),
									location: $0.location
								)
							} ?? .init(),
						startPoint: .leading,
						endPoint: .trailing
					)
				}
				.clipShape(.rect(cornerRadius: 8))
			})
		}
	}
}
