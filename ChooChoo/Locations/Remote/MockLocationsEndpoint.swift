//
//  DatingEndpointImpl.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

final class MockLocationsEndpoint: LocationsEndpoint {
    
    func getLocations(
        lat: Float,
        lon: Float
    ) async -> Result<[any StopResponse], ResponseError> {
        
        // Create some mock stops
        let mockStop1 = MockStopResponse(
            id: "1",
            name: "some Stop",
            latitude: 52.5200,
            longitude: 13.4050,
            type: "stop"
        )
        
        let mockStop2 = MockStopResponse(
            id: "2",
            name: "some Stop",
            latitude: 52.5210,
            longitude: 13.4060,
            type: "stop"
        )
        
        return .success([mockStop1, mockStop2])
    }
}

// A simple struct conforming to StopResponse for mocks
struct MockStopResponse: StopResponse {
    let id: String?
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let type: String?
    
    func stopDTO() -> StopDTO {
        StopDTO(
            type: type,
            id: id,
            name: name,
            address: nil,
            location: nil,
            latitude: latitude,
            longitude: longitude,
            poi: nil,
            products: nil,
            distance: nil,
            station: nil
        )
    }
}
