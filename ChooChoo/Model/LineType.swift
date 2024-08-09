//
//  LineType.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.12.23.
//

import Foundation
import SwiftUI
import CoreLocation

enum LineType : String,Equatable,Hashable, CaseIterable, Codable {
	static func < (lhs: LineType, rhs: LineType) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	case nationalExpress
	case national
	case regionalExpress
	case regional
	case suburban
	case bus
	case replacementBus
	case ferry
	case subway
	case tram
	case taxi
	case transfer
	case foot
}

extension LineType {
	var shortValue : String {
		switch self {
		case .nationalExpress:
			return "ICE"
		case .national:
			return "IC,EC"
		case .regionalExpress:
			return "IRE"
		case .regional:
			return "RE,RB"
		case .suburban:
			return "S-bahn"
		case .bus:
			return "Bus"
		case .replacementBus:
			return "Bus"
		case .ferry:
			return "Ferry"
		case .subway:
			return "U-bahn"
		case .tram:
			return "Tram"
		case .taxi:
			return "Taxi"
		case .transfer:
			return "Transfer"
		case .foot:
			return "Foot"
		}
	}
	
	var icon : String? {
		switch self {
		case .nationalExpress:
			return "ice"
		case .national:
			return "ice"
		case .regionalExpress:
			return "re"
		case .regional:
			return "re"
		case .suburban:
			return "s"
		case .bus:
			return "bus"
		case .replacementBus:
			return "bus"
		case .ferry:
			return "ship"
		case .subway:
			return "u"
		case .tram:
			return "tram"
		case .taxi:
			return "taxi"
		case .transfer:
			return "transfer.big"
		case .foot:
			return "foot.big"
		}
	}
	
	var iconBackgroundStyle : BadgeBackgroundBaseStyle {
		switch self {
		case .replacementBus:
			return .yellow
		default:
			return .clear
		}
	}
	
	var iconBig : String {
		switch self {
		case .nationalExpress:
			return "ice.big"
		case .national:
			return "ice.big"
		case .regionalExpress:
			return "re.big"
		case .regional:
			return "re.big"
		case .suburban:
			return "s.big"
		case .bus:
			return "bus.big"
		case .replacementBus:
			return "bus.big"
		case .ferry:
			return "ship.big"
		case .subway:
			return "u.big"
		case .tram:
			return "tram.big"
		case .taxi:
			return "taxi.big"
		case .transfer:
			return "transfer.big"
		case .foot:
			return "foot.big"
		}
	}
	
	var color : Color {
		switch self {
		case .nationalExpress:
			return Color.transport.iceGray
		case .national:
			return Color.transport.iceGray
		case .regionalExpress:
			return Color.transport.reGray
		case .regional:
			return Color.transport.reGray
		case .suburban:
			return Color.transport.sGreen
		case .bus:
			return Color.transport.busMagenta
		case .replacementBus:
			return Color.transport.busMagenta
		case .ferry:
			return Color.transport.shipCyan
		case .subway:
			return Color.transport.uBlue
		case .tram:
			return Color.transport.tramRed
		case .taxi:
			return Color.transport.taxiYellow
		case .transfer:
			return .clear
		case .foot:
			return Color.chewGrayScale10
		}
	}
}

extension LineType {
	func products() -> Products {
		switch self {
		case .nationalExpress:
			return .init(nationalExpress: true)
		case .national:
			return .init(national: true)
		case .regionalExpress:
			return .init(regionalExpress: true)
		case .regional:
			return .init(regional: true)
		case .suburban:
			return .init(suburban: true)
		case .bus:
			return .init(bus : true)
		case .replacementBus:
			return .init(bus : true)
		case .ferry:
			return .init(ferry: true)
		case .subway:
			return .init(suburban: true)
		case .tram:
			return .init(tram: true)
		case .taxi:
			return .init(taxi: true)
		case .transfer:
			return .init()
		case .foot:
			return .init()
		}
	}
}
extension LineType {
	func stopAnnotation<T : ChewStopAnnotaion>(id: String?,name : String, coords: CLLocationCoordinate2D, stopOverType : StopOverType?) -> T {
		T (
			stopId: id,
			name: name,
			location: coords,
			type: self,
			stopOverType: stopOverType
		)
	}
}

