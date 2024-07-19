//
//  constructJourneyList+Leg.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation

func constructLineViewData(
	product : String,
	name : String,
	productName : String,
	legType : LegViewData.LegType
) -> LineViewData {
	let mode : LineType = {
		switch legType {
		case .transfer:
			return .transfer
		case .line:
			break
		default:
			return .foot
		}
		switch product {
		case "nationalExpress":
			return .nationalExpress
		case "national":
			return .national
		case "regionalExpress":
			return .regionalExpress
		case "regional":
			return .regional
		case "suburban":
			return .suburban
		case "bus":
			return .bus
		case "ferry":
			return .ferry
		case "subway":
			return .subway
		case "tram":
			return .tram
		case "taxi":
			return .taxi
		default:
			return .ferry
		}
	}()
	return LineViewData(
		type: mode,
		name: name,
		shortName: productName
	)
}
