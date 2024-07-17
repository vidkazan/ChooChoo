//
//  CloseButton.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 17.07.24.
//

import Foundation
import SwiftUI

struct CloseButton: View {
	let action : () -> ()
	
	init(action : @escaping () -> ()) {
		self.action = action
	}
	
	var body: some View {
		Button(action: action, label: {
			Image(.xmarkCircle)
				.chewTextSize(.big)
				.tint(.secondary)
		})
	}
}
