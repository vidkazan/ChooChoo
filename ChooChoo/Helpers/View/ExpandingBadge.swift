//
//  ExpandingBadge.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI

extension BadgeView {
	func expandingBadge(_ expandedText: @escaping () -> OneLineText) -> some View {
		ExpandingBadge(isExpanded: false, baseBadge: self, expandedText: expandedText)
	}
}

struct ExpandingBadge: View {
	@Namespace var ExpandingBadge
	@State var isExpanded = false
	let baseBadge : BadgeView
	let expandedText : () -> OneLineText
	var body: some View {
		Button(action: {
			withAnimation {
				isExpanded.toggle()
			}
		}, label: {
			HStack {
				baseBadge
				if isExpanded {
					expandedText()
						.transition(
							.opacity.combined(with: .move(edge: .leading))
						)
				}
			}
			.padding(5)
		})
		
	}
}
