//
//  DatingEndpointImpl.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

final class LocationsEndpointImpl: LocationsEndpoint {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClientImpl()) {
        self.httpClient = httpClient
    }
    
    func getLocations(
        lat: Float,
        lon: Float
    ) async -> Result<[any StopResponse], ResponseError> {
        let query = [
            Query.reiseloesungOrteNearbylong(longitude: String(lon)).queryItem(),
            Query.reiseloesungOrteNearbylat(latitude: String(lat)).queryItem(),
            Query.reiseloesungOrteNearbyMaxNo(numberOfResults: 10).queryItem(),
            Query.reiseloesungOrteNearbyRadius(radius: 5000).queryItem()
        ]
            
        guard let url = RequestFabric.generateUrl(
            query: query,
            type: .locationsNearby
        ) else {
            return .failure(.badRequest)
        }
        
        let result : Result<[StopResponseIntlBahnDe], ResponseError> = await httpClient.execute(
            url: url,
            body: nil
        )
        
        return result.map { stops in
            stops.map { $0 as any StopResponse }
        }
    }
}
