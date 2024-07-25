//
//  TextModifiers.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.10.23.
//

import Foundation
import SwiftUI

protocol BadgeStyle : ViewModifier {}

extension View {
	func badgeBackgroundStyle<Style: BadgeStyle>(_ style: Style) -> some View {
		ModifiedContent(content: self, modifier: style)
	}
}

extension ViewModifier where Self == BadgeBackgroundBaseStyle {
	static var secondary : BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillTertiary.opacity(0.3))
	}
	static var primary: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillTertiary)
	}
	static var red: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillRedPrimary)
	}
	static var green: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillGreenPrimary)
	}
	static var yellow: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillYellowPrimary)
	}
	static var orange: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.orange)
	}
	static var blue: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.transport.uBlue)
	}
	static var accent: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.chewFillAccent)
	}
	static var clear: BadgeBackgroundBaseStyle {
		BadgeBackgroundBaseStyle(Color.clear)
	}
}


struct BadgeBackgroundGradientStyle: BadgeStyle {
	var colors : (Color, Color)
	init(colors : (Color, Color)) {
		self.colors  = colors
	}
	func body(content: Content) -> some View {
		content
			.background( .linearGradient(
				colors: [
					colors.0,
					colors.1
				],
				startPoint: UnitPoint(x: 0, y: 0),
				endPoint: UnitPoint(x: 1, y: 0))
			)
			.cornerRadius(8)
	}
}

struct BadgeBackgroundBaseStyle: BadgeStyle {
	let color : Color
	init(_ color: Color){
		self.color = color
	}
	func body(content: Content) -> some View {
		content
			.background(color)
			.cornerRadius(8)
	}
}
