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
            case "nationalExpress", 
                StopResponseIntlBahnDe.EndpointProducts.nationalExpress.rawValue,
                "national",
                StopResponseIntlBahnDe.EndpointProducts.national.rawValue,
                "regionalExpress",
                StopResponseIntlBahnDe.EndpointProducts.regionalExpress.rawValue,
                "regional",
                StopResponseIntlBahnDe.EndpointProducts.regional.rawValue,
                "suburban",
                StopResponseIntlBahnDe.EndpointProducts.suburban.rawValue,
                "ferry",
                StopResponseIntlBahnDe.EndpointProducts.ferry.rawValue,
                "subway",
                StopResponseIntlBahnDe.EndpointProducts.subway.rawValue,
                "tram",
                StopResponseIntlBahnDe.EndpointProducts.tram.rawValue:
			if name.contains("Bus") || name.contains("bus") {
				return .replacementBus
			}
			break
		default:
			break
		}
		
        
        
		switch product {
        case "nationalExpress", StopResponseIntlBahnDe.EndpointProducts.nationalExpress.rawValue:
			return .nationalExpress
		case "national",StopResponseIntlBahnDe.EndpointProducts.national.rawValue:
			return .national
		case "regionalExpress", StopResponseIntlBahnDe.EndpointProducts.regionalExpress.rawValue:
			return .regionalExpress
		case "regional",StopResponseIntlBahnDe.EndpointProducts.regional.rawValue:
			return .regional
		case "suburban",StopResponseIntlBahnDe.EndpointProducts.suburban.rawValue:
			return .suburban
		case "bus",StopResponseIntlBahnDe.EndpointProducts.bus.rawValue:
			return .bus
		case "ferry",StopResponseIntlBahnDe.EndpointProducts.ferry.rawValue:
			return .ferry
		case "subway",StopResponseIntlBahnDe.EndpointProducts.subway.rawValue:
			return .subway
		case "tram",StopResponseIntlBahnDe.EndpointProducts.tram.rawValue:
			return .tram
		case "taxi",StopResponseIntlBahnDe.EndpointProducts.taxi.rawValue:
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
