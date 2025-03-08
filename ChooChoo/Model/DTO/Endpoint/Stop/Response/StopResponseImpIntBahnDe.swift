//
//  StopEndpointDTO.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

struct StopResponseIntlBahnDe : StopResponse {
    let extId: String?
    let id: String?
    let lat: Double?
    let lon: Double?
    let name: String?
    let products: [String]
    let type: String?
    
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

extension StopResponseIntlBahnDe {
    func stopDTO() -> StopDTO {
        // TODO: locaiton is hardcoded nil!
        let stopType : StopType? = StopType(rawValue: self.type ?? "")
        
        return StopDTO(
            type: self.type,
            id: self.id,
            name: self.name,
            address: stopType != .station ? self.name : nil,
            location: nil,
            latitude: self.lat,
            longitude: self.lon,
            poi: stopType == .pointOfInterest,
            products: Products(
                nationalExpress: self.products.firstIndex(of: Self.EndpointProducts.nationalExpress.rawValue) != nil,
                national: self.products.firstIndex(of: Self.EndpointProducts.national.rawValue) != nil,
                regionalExpress: self.products.firstIndex(of: Self.EndpointProducts.regionalExpress.rawValue) != nil,
                regional: self.products.firstIndex(of: Self.EndpointProducts.regional.rawValue) != nil,
                suburban: self.products.firstIndex(of: Self.EndpointProducts.suburban.rawValue) != nil,
                bus: self.products.firstIndex(of: Self.EndpointProducts.bus.rawValue) != nil,
                ferry: self.products.firstIndex(of: Self.EndpointProducts.ferry.rawValue) != nil,
                subway: self.products.firstIndex(of: Self.EndpointProducts.subway.rawValue) != nil,
                tram: self.products.firstIndex(of: Self.EndpointProducts.tram.rawValue) != nil,
                taxi: self.products.firstIndex(of: Self.EndpointProducts.taxi.rawValue) != nil
            ),
            distance: nil,
            station: nil
        )
    }
}

extension StopResponseIntlBahnDe {
    enum EndpointProducts : String, Hashable, CaseIterable {
        case nationalExpress="ICE"
        case national="EC_IC"
        case regionalExpress="IR"
        case regional="REGIONAL"
        case suburban="SBAHN"
        case bus="BUS"
        case ferry="SCHIFF"
        case subway="UBAHN"
        case tram = "TRAM"
        case taxi = "ANRUFPFLICHTIG"
    }
}

extension StopResponseIntlBahnDe {
    enum StopType : String {
        case station = "ST"
        case address = "ADR"
        case pointOfInterest = "POI"
    }
}
