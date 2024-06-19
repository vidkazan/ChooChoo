//
//  MapPickerLocationPickTipView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI
import ChooViews

extension ChooTip.Labels {
	struct MapPickerLocationPickTipView: View {
		let onClose : () -> ()
		var body: some View {
			HStack {
				Label(
					title: {
						Text("**Long tap** to pick custom location", comment: "mapPickerTip")
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
			.foregroundStyle(.secondary)
			.badgeBackgroundStyle(.accent)
			.clipShape(.rect(cornerRadius: 8))
		}
	}
}


