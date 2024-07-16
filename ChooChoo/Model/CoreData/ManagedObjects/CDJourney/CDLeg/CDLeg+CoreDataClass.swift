//
//  CDLeg+CoreDataClass.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.12.23.
//
//

import Foundation
import CoreData

@objc(CDLeg)
public class CDLeg: NSManagedObject {

}

extension CDLeg {
	convenience init(
		context : NSManagedObjectContext,
		leg : LegViewData,
		for journey : CDJourney
	){
		self.init(entity: CDLeg.entity(), insertInto: context)
		self.tripId = leg.tripId
		self.isReachable = leg.isReachable
		self.legBottomPosition = leg.legBottomPosition
		self.legTopPosition = leg.legTopPosition
		self.lineName = leg.lineViewData.name
		self.lineShortName = leg.lineViewData.shortName
		self.lineType = leg.lineViewData.type.rawValue
		if let legDTO = try? JSONEncoder().encode(leg.legDTO) {
			self.legDTO = legDTO
		}
		if let legType = try? JSONEncoder().encode(leg.legType) {
			self.legType = legType
		}
				
		self.journey = journey
		
		if let time = leg.time.encode() {
			self.time = time
		}
		
		for stop in leg.legStopsViewData {
			let _ = CDStop(insertInto: context, with: stop, to: self)
		}
	}
}

extension CDLeg {
	func legViewData() -> LegViewData? {
		var stopsViewData = [StopViewData]()
		
		stopsViewData = stops.map { $0.stopViewData() }
		
		let segments = segments(from : stopsViewData)
		guard let time = TimeContainer(isoEncoded: self.time) else {
			return nil
		}
		
		let legDTOobj : LegDTO? = {
			if let legDTOdata = legDTO {
				return try? JSONDecoder().decode(LegDTO.self,from: legDTOdata)
			}
			return nil
		}()
		
		guard let legTypeData = self.legType,
		   let legType = try? JSONDecoder().decode(LegViewData.LegType.self,from: legTypeData) else {
				return nil
		}
		guard let direction = self.stops.last?.stopViewData().stop() else {
			return nil
		}
		return LegViewData(
			isReachable: self.isReachable,
			legType: legType,
			tripId: self.tripId,
			direction: direction,
			legTopPosition: self.legTopPosition,
			legBottomPosition: self.legBottomPosition,
			remarks: [],
			legStopsViewData: stopsViewData,
			footDistance: -1,
			lineViewData: LineViewData(
				type: LineType(rawValue: self.lineType) ?? .taxi,
				name: self.lineName,
				shortName: self.lineShortName
			),
			progressSegments: segments,
			time: time,
			polyline: nil,
			legDTO : legDTOobj
		)
	}
}
