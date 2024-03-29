//
//  SheetViewDataSource.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 07.03.24.
//

import Foundation
import MapKit
import OrderedCollections

protocol SheetViewDataSource {}

struct MapLegData : Hashable {
	let type : LegViewData.LegType
	let lineType : LineType
	let stops : [StopViewData]
	let route : MKPolyline?
	let currenLocation : Coordinate?
}

enum MapDetailsRequest {
	case footDirection(_ leg : LegViewData)
	case lineLeg(_ leg : LegViewData)
	case journey(_ legs : [LegViewData])
}

struct MapDetailsViewDataSource : SheetViewDataSource {
	let coordRegion : MKCoordinateRegion
	let mapLegDataList : OrderedSet<MapLegData>
}

struct JourneyDebugViewDataSource : SheetViewDataSource {
	let legDTOs : [LegDTO]
}
struct RouteViewDataSource : SheetViewDataSource {
	let leg : LegViewData
}
struct RemarksViewDataSource : SheetViewDataSource {
	let remarks : [RemarkViewData]
}
struct DatePickerViewDataSource	: SheetViewDataSource {}
struct EmptyDataSource				: SheetViewDataSource {}
struct JourneySettingsViewDataSource		: SheetViewDataSource {}
struct AppSettingsViewDataSource		: SheetViewDataSource {}
struct OnboardingViewDataSource	: SheetViewDataSource {}
struct InfoDataSource				: SheetViewDataSource {}
struct MapPickerViewDataSource	: SheetViewDataSource {}
