//
//  ChooButton.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI
import OSLog

extension Button {
	init(
		buttonID : ChooButtonID,
		action: @escaping () -> Void,
		@ViewBuilder label: () -> Label
	) {
		self.init(
			action: {
				Logger.buttonTap.trace("\(buttonID.rawValue)")
				action()
			},
			label: label
		)
	}
}

extension View {
	func onTapGesture(
		onTapId : ChooOnTapID,
		perform action: @escaping () -> Void
	) -> some View {
		self
		.onTapGesture(perform: {
			Logger.tapNonTappable.trace("\(onTapId.rawValue)")
			action()
		})
	}
}
