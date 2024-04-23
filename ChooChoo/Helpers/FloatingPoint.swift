//
//  Floating.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation

extension FloatingPoint {
	var degreesToRadians: Self { self * .pi / 180 }
	var radiansToDegrees: Self { self * 180 / .pi }
}
