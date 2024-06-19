//
//  ExpandingBadge.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI
import ChooViews

extension BadgeView {
	func expandingBadge<V>(@ViewBuilder _ expandedView: @escaping () -> V) -> some View where V : View {
		ExpandingBadge(
			BadgeView.self,
			isExpanded: false,
			baseBadge: self,
 			expandedView: expandedView
		)
	}
}
