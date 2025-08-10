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
		action: @escaping () -> Void,
		@ViewBuilder label: () -> Label,
		buttonID : ChooButtonID
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
		perform action: @escaping () -> Void,
		onTapId : ChooOnTapID
	) -> some View {
		self
        .highPriorityGesture(
            TapGesture().onEnded {
                Logger.tapNonTappable.trace("\(onTapId.rawValue)")
                action()
            }
        )
	}
}
