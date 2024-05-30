//
//  Chew_chew_UnitTests.swift
//  Chew-chew-UnitTests
//
//  Created by Dmitrii Grigorev on 26.11.23.
//

import CoreLocation
import XCTest
@testable import ChooChoo

final class ChooChooTripTest: XCTestCase {
	func testNormalTrip() {
		runTest(with: Mock.trip.RE6NeussMinden.decodedData!)
	}
	
	func testTripCancelledFirstStop() {
		runTest(with: Mock.trip.cancelledFirstStopRE11DussKassel.decodedData!)
	}
	
	func testTripCancelledLastStop() {
		runTest(with: Mock.trip.cancelledLastStopRE11DussKassel.decodedData!)
	}
}

extension ChooChooTripTest {
	fileprivate func runTest(with data: TripDTO) {
		XCTAssertNil(data)
		
		let actualViewData: LegViewData? = data.trip.legViewData(
			firstTS: .now,
			lastTS: .now,
			legs: nil
		)
		
		XCTAssertNil(actualViewData)
		XCTAssertEqual(actualViewData?.time.durationInMinutes, 222)
		XCTAssertEqual(actualViewData?.direction, "Minden(Westf)")
	}

}
