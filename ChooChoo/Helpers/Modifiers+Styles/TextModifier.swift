//
//  TextModifiers.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.10.23.
//

import Foundation
import SwiftUI

protocol ChewTextStyle : ViewModifier {}

enum ChewTextSize : Int, CaseIterable, Equatable {
	case small
	case medium
	case big
	case huge
	
	var chewTextStyle : ChewPrimaryStyle {
		switch self {
		case .small:
			return .small
		case .medium:
			return .medium
		case .big:
			return .big
		case .huge:
			return .huge
		}
	}
}

extension View {
	func chewTextSize<Style: ChewTextStyle>(_ style: Style) -> some View {
		ModifiedContent(content: self, modifier: style)
	}
}

extension ViewModifier where Self == ChewPrimaryStyle {
	static var huge: ChewPrimaryStyle {
		ChewPrimaryStyle(20,.title2)
	}
	static var big: ChewPrimaryStyle {
		ChewPrimaryStyle(17,.body)
	}
	static var small: ChewPrimaryStyle {
		ChewPrimaryStyle(9,.caption2)
	}
	static var medium: ChewPrimaryStyle {
		ChewPrimaryStyle(12,.caption)
	}
}

struct ChewPrimaryStyle: ChewTextStyle {
	let size : CGFloat!
	let font : Font.TextStyle!
	init(_ size : CGFloat, _ font : Font.TextStyle){
		self.size = size
		self.font = font
	}
	func body(content: Content) -> some View {
		content
			.font(.system(size: size,weight: .semibold))
	}
	
	var padding : Int {
		Int(size/3)
	}
}


#if DEBUG
struct Font_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ForEach(Font.TextStyle.allCases, id: \.hashValue, content: {
				Text("popopopo")
					.font(.system($0))
			})
		}
	}
}
#endif
