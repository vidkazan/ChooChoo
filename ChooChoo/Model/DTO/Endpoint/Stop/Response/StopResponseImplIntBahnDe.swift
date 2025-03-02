//
//  StopEndpointDTO.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

struct IntlBahnDeStopEndpointDTO {
    let extId: String
    let id: String
    let lat: Double
    let lon: Double
    let name: String
    let products: [String]
    let type: String
    
    private enum CodingKeys : String, CodingKey {
        case extId
        case id
        case lat
        case lon
        case name
        case products
        case type
    }
}

extension IntlBahnDeStopEndpointDTO : StopResponse {
    func stopDTO() -> StopDTO {
        // TODO: locaiton is hardcoded nil!
        let stopType : StopType? = StopType(rawValue: self.type)
        
        return StopDTO(
            type: self.type,
            id: self.extId,
            name: self.name,
            address: stopType != .station ? self.name : nil,
            location: nil,
            latitude: self.lat,
            longitude: self.lon,
            poi: stopType == .pointOfInterest,
            products: Products(
                nationalExpress: self.products.firstIndex(of: "ICE") != nil,
                national: self.products.firstIndex(of: "EC_IC") != nil,
                regionalExpress: self.products.firstIndex(of: "IR") != nil,
                regional: self.products.firstIndex(of: "REGIONAL") != nil,
                suburban: self.products.firstIndex(of: "SBAHN") != nil,
                bus: self.products.firstIndex(of: "BUS") != nil,
                ferry: self.products.firstIndex(of: "SCHIFF") != nil,
                subway: self.products.firstIndex(of: "UBAHN") != nil,
                tram: self.products.firstIndex(of: "TRAM") != nil,
                taxi: self.products.firstIndex(of: "ANRUFPFLICHTIG") != nil
            ),
            distance: nil,
            station: nil
        )
    }
}

extension IntlBahnDeStopEndpointDTO {
    enum StopType : String {
        case station = "ST"
        case address = "ADR"
        case pointOfInterest = "POI"
    }
}
