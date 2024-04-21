//
//  StopListCell.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.03.24.
//

import Foundation
import SwiftUI

struct StopListCell : View {
	let stop : StopWithDistance
	var isMultiline : Bool
	init(stop: StopWithDistance, isMultiline : Bool = false) {
		self.stop = stop
		self.isMultiline = isMultiline
	}
	
	init(stop: Stop,isMultiline : Bool = false) {
		self.stop = StopWithDistance(
			stop: stop,
			distance: nil
		)
		self.isMultiline = isMultiline
	}
	var body: some View {
		Group {
			if let lineType = stop.stop.stopDTO?.products?.lineType,
				let icon = lineType.icon {
				Label {
					Text(verbatim: stop.stop.name)
						.lineLimit(isMultiline ? 2 : 1)
				} icon: {
					Image(icon)
						.padding(5)
						.frame(width: 30)
						.aspectRatio(1, contentMode: .fill)
						.badgeBackgroundStyle(BadgeBackgroundBaseStyle(lineType.color))
				}
			} else {
				Label(
					title: {
						Text(verbatim: stop.stop.name)
							.lineLimit(isMultiline ? 2 : 1)
					},
					icon: {
						Image(systemName: stop.stop.type.SFSIcon)
							.frame(width: 30)
					}
				)
			}
		}
		.padding(5)
		.chewTextSize(.big)
		.foregroundStyle(.primary)
		.frame(alignment: .leading)
	}
}

