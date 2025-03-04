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
                IntlBahnDeStopEndpointDTO.EndpointProducts.nationalExpress.rawValue,
                "national",
                IntlBahnDeStopEndpointDTO.EndpointProducts.national.rawValue,
                "regionalExpress",
                IntlBahnDeStopEndpointDTO.EndpointProducts.regionalExpress.rawValue,
                "regional",
                IntlBahnDeStopEndpointDTO.EndpointProducts.regional.rawValue,
                "suburban",
                IntlBahnDeStopEndpointDTO.EndpointProducts.suburban.rawValue,
                "ferry",
                IntlBahnDeStopEndpointDTO.EndpointProducts.ferry.rawValue,
                "subway",
                IntlBahnDeStopEndpointDTO.EndpointProducts.subway.rawValue,
                "tram",
                IntlBahnDeStopEndpointDTO.EndpointProducts.tram.rawValue:
			if name.contains("Bus") || name.contains("bus") {
				return .replacementBus
			}
			break
		default:
			break
		}
		
        
        
		switch product {
        case "nationalExpress", IntlBahnDeStopEndpointDTO.EndpointProducts.nationalExpress.rawValue:
			return .nationalExpress
		case "national",IntlBahnDeStopEndpointDTO.EndpointProducts.national.rawValue:
			return .national
		case "regionalExpress", IntlBahnDeStopEndpointDTO.EndpointProducts.regionalExpress.rawValue:
			return .regionalExpress
		case "regional",IntlBahnDeStopEndpointDTO.EndpointProducts.regional.rawValue:
			return .regional
		case "suburban",IntlBahnDeStopEndpointDTO.EndpointProducts.suburban.rawValue:
			return .suburban
		case "bus",IntlBahnDeStopEndpointDTO.EndpointProducts.bus.rawValue:
			return .bus
		case "ferry",IntlBahnDeStopEndpointDTO.EndpointProducts.ferry.rawValue:
			return .ferry
		case "subway",IntlBahnDeStopEndpointDTO.EndpointProducts.subway.rawValue:
			return .subway
		case "tram",IntlBahnDeStopEndpointDTO.EndpointProducts.tram.rawValue:
			return .tram
		case "taxi",IntlBahnDeStopEndpointDTO.EndpointProducts.taxi.rawValue:
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
