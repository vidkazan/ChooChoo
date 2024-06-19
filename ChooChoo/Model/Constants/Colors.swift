//
//  Colors.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 27.09.23.
//
//
//import Foundation
//import SwiftUI
//
//struct TransportColors {
//	var busMagenta: Color {
//		Color("busMagenta")
//	}
//	var iceGray: Color {
//		Color("iceGray")
//	}
//	var reGray: Color {
//		Color("reGray")
//	}
//	var shipCyan: Color {
//		Color("shipCyan")
//	}
//	var sGreen: Color {
//		Color("sGreen")
//	}
//	var uBlue: Color {
//		Color("uBlue")
//	}
//	var taxiYellow: Color {
//		Color("taxiYellow")
//	}
//	var tramRed: Color {
//		Color("tramRed")
//	}
//}
//
//extension ShapeStyle where Self == Color {
//	
//	static var chewSunEventBlue: Color {
//		Color("ChewSunEventBlue")
//	}
//	static var chewLegDetailsCellGray: Color {
//		Color("ChewLegDetailsCellGray")
//	}
//	static var chewLegsViewGray: Color {
//		Color("ChewLegsViewGray")
//	}
//	static var chewFillMagenta: Color {
//		Color("ChewFillMagenta")
//	}
//	static var chewFillPrimary: Color {
//		Color("ChewFillPrimary")
//	}
//	static var chewFillSecondary: Color {
//		Color("ChewFillSecondary")
//	}
//	static var chewFillAccent: Color {
//		Color("ChewFillAccent")
//	}
//	static var chewFillTertiary: Color {
//		Color("ChewFillTertiary")
//	}
//	
//	static var chewFillGreenSecondary: Color {
//		Color("ChewFillGreenSecondary")
//	}
//	static var chewFillGreenPrimary: Color {
//		Color("ChewFillGreenPrimary")
//	}
//	
//	static var chewFillBluePrimary: Color {
//		Color("ChewFillBluePrimary")
//	}
//	static var chewFillYellowPrimary: Color {
//		Color("ChewFillYellowPrimary")
//	}
//	static var chewFillRedPrimary: Color {
//		Color("ChewFillRedPrimary")
//	}
//	
//	static var chewProgressLineGray: Color {
//		Color("ChewProgressLineGray")
//	}
//	static var chewTimeLabelGray: Color {
//		Color("ChewTimeLabelGray")
//	}
//}
//extension Color {
//	static var transport = TransportColors()
//	
//	static var chewSunEventBlue: Color {
//		Color("ChewSunEventBlue")
//	}
//	static var chewSunEventYellow: Color {
//		Color("ChewSunEventYellow")
//	}
//	static var chewLegDetailsCellGray: Color {
//		Color("ChewLegDetailsCellGray")
//	}
//	static var chewStopListBG: Color {
//		Color("ChewStopListBG")
//	}
//	static var chewTimeChoosingViewBG: Color {
//		Color("ChewTimeChoosingViewBG")
//	}
//	static var chewLegsViewGray: Color {
//		Color("ChewLegsViewGray")
//	}
//	static var chewFillMagenta: Color {
//		Color("ChewFillMagenta")
//	}
//	static var chewFillPrimary: Color {
//		Color("ChewFillPrimary")
//	}
//	static var chewFillSecondary: Color {
//		Color("ChewFillSecondary")
//	}
//	static var chewFillAccent: Color {
//		Color("ChewFillAccent")
//	}
//	static var chewFillTertiary: Color {
//		Color("ChewFillTertiary")
//	}
//	
//	static var chewFillGreenSecondary: Color {
//		Color("ChewFillGreenSecondary")
//	}
//	static var chewFillGreenPrimary: Color {
//		Color("ChewFillGreenPrimary")
//	}
//	
//	static var chewFillBluePrimary: Color {
//		Color("ChewFillBluePrimary")
//	}
//	static var chewFillYellowPrimary: Color {
//		Color("ChewFillYellowPrimary")
//	}
//	static var chewFillRedPrimary: Color {
//		Color("ChewFillRedPrimary")
//	}
//	
//	
//	static var chewProgressLineGray: Color {
//		Color("ChewProgressLineGray")
//	}
//	static var chewTimeLabelGray: Color {
//		Color("ChewTimeLabelGray")
//	}
//}
//
//extension Color {
//	public static var chewGray07: Color {
//		return Color.gray.opacity(0.07)
//	}
//	public static var chewGray10: Color {
//		return Color.gray.opacity(0.1)
//	}
//	public static var chewGray11: Color {
//		return Color.gray.opacity(0.11)
//	}
//	public static var chewGray15: Color {
//		return Color.gray.opacity(0.15)
//	}
//	public static var chewGray20: Color {
//		return Color.gray.opacity(0.2)
//	}
//	public static var chewGray30: Color {
//		return Color.gray.opacity(0.3)
//	}
//	public static var chewGray50: Color {
//		return Color.gray.opacity(0.5)
//	}
//	
//	public static var chewGrayScale10: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.1)
//	}
//	public static var chewGrayScale05: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.05)
//	}
//		
//	public static var chewGrayScale07: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.07)
//	}
//	
//	public static var chewGrayScale20: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.2)
//	}
//	public static var chewGrayScale30: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.3)
//	}
//	public static var chewGrayScale15: Color {
//		return Color(hue: 0, saturation: 0, brightness: 0.15)
//	}
//	public static var chewRedScale20: Color {
//		return Color(hue: 0, saturation: 1, brightness: 0.2)
//	}
//	public static var chewRedScale30: Color {
//		return Color(hue: 0, saturation: 1, brightness: 0.3)
//	}
//	public static var chewRedScale80: Color {
//		return Color(hue: 0, saturation: 1, brightness: 0.8)
//	}
//	
//	public static var chewYellow: Color {
//		return Color(hue: 0.12, saturation: 1, brightness: 0.7)
//	}
//	
//	public static var chewBlue: Color {
//		return Color(hue: 0.58, saturation: 1, brightness: 0.15)
//	}
//	
//	public static var chewGreenScale10: Color {
//		return Color(hue: 0.45, saturation: 1, brightness: 0.1)
//	}
//	public static var chewGreenScale20: Color {
//		return Color(hue: 0.45, saturation: 1, brightness: 0.2)
//	}
//	
//}
