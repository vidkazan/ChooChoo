//
//  ChooCoreDataStoreTest.swift
//  ChooChooUITests
//
//  Created by Dmitrii Grigorev on 30.05.24.
//

import XCTest
import CoreData
@testable import ChooChoo

final class ChooCoreDataStoreTest: XCTestCase {
	let coreDataStore = CoreDataStore.preview
	let dataName = Mock.journeys.journeyNeussWolfsburg

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


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test() throws {
		
		
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
