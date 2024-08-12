//
//  ExpandingBadge.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI

extension View {
	func expandingBadge<V>(@ViewBuilder _ expandedView: @escaping () -> V) -> some View where V : View {
		ExpandingBadge(
			isExpanded: false,
			baseBadge: self,
			expandedView: expandedView
		)
	}
}

struct ExpandingBadge<T: View, V : View>: View {
	@Namespace var ExpandingBadge
	@State var isExpanded = false
	let baseBadge : V
	let expandedView : () -> T
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
