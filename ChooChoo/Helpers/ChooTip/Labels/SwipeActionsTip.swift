//
//  SwipeActionsTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI

extension ChooTip.Labels {
	struct SwipeActionsTip : View {
		@Environment(\.colorScheme) var colorScheme
		@State private var anim : AnimCase = .center0
		let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
		var body: some View {
			HStack(spacing: 0) {
				Group {
					Color.chewFillGreenSecondary
					Color.chewFillYellowPrimary
				}
				.frame(width: anim.leftCellsWidth)
				Rectangle()
					.fill(
						colorScheme == .dark ? Color.chewFillAccent : .white
					)
					.overlay{
						Text("Swipe for options",comment: "SwipeActionsTip")
							.chewTextSize(.medium)
							.foregroundStyle(.primary.opacity(0.8))
					}
				Color.chewFillRedPrimary
					.frame(width: anim.rightCellsWidth)
			}
			.frame(height: 40)
			.clipShape(.rect(cornerRadius: 10))
			.onReceive(timer, perform: { _ in
				withAnimation(.spring, {
					anim = anim.next()
				})
			})
		}
		
		private enum AnimCase : String,CaseIterable {
			case center0
			case right
			case center1
			case left
			
			var leftCellsWidth : CGFloat {
				switch self {
				case .center0:
					return 0
				case .right:
					return 40
				case .center1:
					return 0
				case .left:
					return 0
				}
			}
			var rightCellsWidth : CGFloat {
				switch self {
				case .center0:
					return 0
				case .right:
					return 0
				case .center1:
					return 0
				case .left:
					return 40
				}
			}
		}
	}
}
