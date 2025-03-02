//
//  JourneyRequestImplIntBahnDe.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

struct JourneyRequestIntBahnDe: JourneyRequest, Codable {
    let id = UUID()
    
    let abfahrtsHalt: String
    let anfrageZeitpunkt: String
    let ankunftsHalt: String
    let ankunftSuche: String
    let klasse: String
    let produktgattungen: [String]
    let schnelleVerbindungen: Bool
    let sitzplatzOnly: Bool
    let bikeCarriage: Bool
    let reservierungsKontingenteVorhanden: Bool
    let nurDeutschlandTicketVerbindungen: Bool
    let deutschlandTicketVorhanden: Bool

    enum CodingKeys: String, CodingKey {
        case abfahrtsHalt
        case anfrageZeitpunkt
        case ankunftsHalt
        case ankunftSuche
        case klasse
        case produktgattungen
        case schnelleVerbindungen
        case sitzplatzOnly
        case bikeCarriage
        case reservierungsKontingenteVorhanden
        case nurDeutschlandTicketVerbindungen
        case deutschlandTicketVorhanden
    }
}

// MARK: - Ermaessigung (Discount) Model
struct Ermaessigung: ChewDTO {
    let art: String
    let klasse: String
}
