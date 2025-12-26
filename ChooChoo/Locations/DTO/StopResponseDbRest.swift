//
//  StopResponseDbRest.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

struct StopEndpointDtoDBrest : StopResponse {
    let type    : String?
    let id        : String?
    let name    : String?
    let address        : String?
    let location    : LocationCoordinatesDTO?
    let latitude    : Double?
    let longitude    : Double?
    let poi            : Bool?
    let products    : Products?
    let distance      : Int?
    let station        : StationDTO?
    
    private enum CodingKeys : String, CodingKey {
        case type
        case id
        case name
        case address
        case location
        case products
        case latitude
        case longitude
        case poi
        case distance
        case station
    }
}

extension StopEndpointDtoDBrest {
    func stopDTO() -> StopDTO {
        StopDTO(
            type: self.type,
            id: self.id,
            name: self.name,
            address: self.address,
            location: self.location,
            latitude: self.latitude,
            longitude: self.longitude,
            poi: self.poi,
            products: self.products,
            distance: self.distance,
            station: self.station
        )
    }
}
