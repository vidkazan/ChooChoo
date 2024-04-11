//
//  ErrorView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.03.24.
//

import Foundation
import SwiftUI

struct ErrorView : View {
	enum ViewType : String,Hashable, CaseIterable {
		case error
		case alert
	}
	let viewType : ViewType
	let msg : Text
	let size : ChewPrimaryStyle
	let action : (() -> Void)?
	var body: some View {
		HStack(spacing: 2) {
			if let action = action {
				Button(action: action, label: {
					Image(.exclamationmarkCircle)
				})
			}
			Label(
				title: {
					msg
						.padding(5)
				},
				icon: {
					Image(viewType == .error ? ChooSFSymbols.exclamationmarkCircle : ChooSFSymbols.infoCircle)
				}
			)
		}
		.chewTextSize(size)
	}
}
