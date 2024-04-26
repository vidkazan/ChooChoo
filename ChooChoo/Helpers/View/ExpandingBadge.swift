//
//  ExpandingBadge.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI

extension BadgeView {
	func expandingBadge<V>(@ViewBuilder _ expandedView: @escaping () -> V) -> some View where V : View {
		ExpandingBadge(
			isExpanded: false,
			baseBadge: self,
			expandedView: expandedView
		)
	}
}

struct ExpandingBadge<Content: View>: View {
	@Namespace var ExpandingBadge
	@State var isExpanded = false
	let baseBadge : BadgeView
	let expandedView : () -> Content
	var body: some View {
		Button(action: {
			withAnimation {
				isExpanded.toggle()
			}
		}, label: {
			HStack {
				baseBadge
				if isExpanded {
					expandedView()
						.transition(
							.opacity.combined(with: .move(edge: .leading))
						)
				}
			}
			.padding(5)
		})
		
	}
}
