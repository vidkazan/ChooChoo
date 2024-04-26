//
//  ReloadButton.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI

struct ReloadableButtonLabel: View {
	enum ReloadableButtonStatus {
		case idle
		case loading
		case error
	}
	
	let state : ReloadableButtonStatus
	let mainIcon : ChooSFSymbols
	let errorIcon : ChooSFSymbols
	
	init(
		state : ReloadableButtonStatus,
		mainIcon: ChooSFSymbols = .arrowClockwise,
		errorIcon: ChooSFSymbols = .exclamationmarkCircle
	) {
		self.state = state
		self.mainIcon = mainIcon
		self.errorIcon = errorIcon
	}
	
	var body: some View {
		Group {
			switch state {
			case .loading:
				ProgressView()
			case .idle:
				mainIcon.view
			case .error:
				errorIcon.view
			}
		}
		.frame(width: 15,height: 15)
		.padding(5)
	}
}
