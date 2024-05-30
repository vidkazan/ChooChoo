//
//  Chew_chew_UnitTests.swift
//  Chew-chew-UnitTests
//
//  Created by Dmitrii Grigorev on 26.11.23.
//

import XCTest
import CoreLocation
@testable import ChooChoo

final class Chew_chew_JourneyTest: XCTestCase {
	let dataName = Mock.journeys.journeyNeussWolfsburg
	let accuracy = 0.000001

	var APIdecodedData : JourneyWrapper!
	var actualViewData : JourneyViewData!


	override func setUpWithError() throws {
		let data = dataName.decodedData
		self.APIdecodedData = data
		
		actualViewData = data?.journey.journeyViewData(
			depStop: nil,
			arrStop: nil,
			realtimeDataUpdatedAt: 0,
			settings: .init()
		)
	}

	func testJourneyViewData() {
		XCTAssertEqual(actualViewData.badges.count, 1)
		XCTAssertEqual(actualViewData.origin,APIdecodedData.journey.legs.first?.origin?.name)
		XCTAssertEqual(actualViewData.destination,APIdecodedData.journey.legs.last?.destination?.name)
		XCTAssertEqual(actualViewData.time.durationInMinutes,317)
		XCTAssertEqual(actualViewData.transferCount,2)
		XCTAssertEqual(actualViewData.time.iso.departure.planned,"2023-11-27T13:36:00+01:00")
		XCTAssertEqual(actualViewData.time.iso.arrival.planned,"2023-11-27T18:43:00+01:00")
		XCTAssertEqual(actualViewData.legs.count,5)
	}

	func testLegType() {
		XCTAssertEqual(constructLegType(leg: APIdecodedData.journey.legs[0], legs: APIdecodedData.journey.legs),.line)
		XCTAssertEqual(constructLegType(leg: APIdecodedData.journey.legs[1], legs: APIdecodedData.journey.legs),.line)
		XCTAssertEqual(constructLegType(leg: APIdecodedData.journey.legs[2], legs: APIdecodedData.journey.legs),.line)
	}

	func testFirstLeg() {
		let legs = actualViewData.legs

		let leg = legs.first!

		XCTAssertEqual(leg.legType, .line)
		XCTAssertNil(leg.delayedAndNextIsNotReachable)
		XCTAssertEqual(leg.direction, "Minden(Westf)")
		XCTAssertEqual(leg.time.durationInMinutes, 174)
		XCTAssertEqual(leg.footDistance, 0)
		XCTAssertTrue(leg.isReachable)
		XCTAssertEqual(leg.legBottomPosition, 0.5488958990536278, accuracy: self.accuracy)
		XCTAssertEqual(leg.legTopPosition, 0,accuracy: self.accuracy)
		XCTAssertEqual(leg.tripId, APIdecodedData.journey.legs.first?.tripId)
	}

	func testSecondLeg() {
		let legs = actualViewData.legs

		let leg = legs[1]

		XCTAssertEqual(leg.legType, .transfer)
		XCTAssertNotNil(leg.delayedAndNextIsNotReachable)
		XCTAssertEqual(leg.direction, "Minden(Westf)")
		XCTAssertEqual(leg.time.durationInMinutes, 5)
		XCTAssertEqual(leg.footDistance, 0)
		XCTAssertTrue(leg.isReachable)
		XCTAssertEqual(leg.legBottomPosition, 0, accuracy: self.accuracy)
		XCTAssertEqual(leg.legTopPosition, 0,accuracy: self.accuracy)
		XCTAssertNotNil(leg.tripId)
	}

	func testLastLeg() {
		let legs = actualViewData.legs

		let leg = legs.last!

		XCTAssertEqual(leg.legType, .line)
		XCTAssertNil(leg.delayedAndNextIsNotReachable)
		XCTAssertEqual(leg.direction, "Wolfsburg Hbf")
		XCTAssertEqual(leg.time.durationInMinutes, 65)
		XCTAssertEqual(leg.footDistance, 0)
		XCTAssertTrue(leg.isReachable)
		XCTAssertEqual(leg.legBottomPosition, 1, accuracy: self.accuracy)
		XCTAssertEqual(leg.legTopPosition, 0.7949526813880127, accuracy: self.accuracy)
		XCTAssertEqual(leg.tripId, APIdecodedData.journey.legs.last?.tripId)
	}
}
