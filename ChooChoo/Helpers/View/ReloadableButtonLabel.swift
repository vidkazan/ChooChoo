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
	
	let stateFn : () -> ReloadableButtonStatus
	
	init(_ stateFn: @escaping () -> ReloadableButtonStatus) {
		self.stateFn = stateFn
	}
	
	@State var state : ReloadableButtonStatus = .idle
	var body: some View {
		Group {
			switch state {
			case .loading:
				ProgressView()
			case .idle:
				Image(.arrowClockwise)
			case .error:
				Image(.exclamationmarkCircle)
			}
		}
		.onAppear {
			state = stateFn()
		}
		.frame(width: 15,height: 15)
		.padding(5)
	}
}

