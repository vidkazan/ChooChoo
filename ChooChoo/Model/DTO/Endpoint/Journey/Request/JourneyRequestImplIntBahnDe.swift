//
//  JourneyRequestImplIntBahnDe.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

struct JourneyRequestIntBahnDe : ChewDTO {
    var date: Date = .now
    
    var maxUmstiege : Int
    var abfahrtsHalt: String
    var anfrageZeitpunkt: String
    var ankunftsHalt: String
    var ankunftSuche: String
    var klasse: String
    var produktgattungen: [String]
    var schnelleVerbindungen: Bool
    var sitzplatzOnly: Bool
    var bikeCarriage: Bool
    var reservierungsKontingenteVorhanden: Bool
    var nurDeutschlandTicketVerbindungen: Bool
    var deutschlandTicketVorhanden: Bool
    var pagingReference : String
    var reisende : [Reisende]
    
    enum CodingKeys: String, CodingKey {
        case maxUmstiege
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
        case pagingReference
        case reisende
    }
}

extension JourneyRequestIntBahnDe {
    init() {
        self.maxUmstiege = 0
        self.abfahrtsHalt = ""
        self.anfrageZeitpunkt = ""
        self.ankunftsHalt = ""
        self.ankunftSuche = ""
        self.klasse = ""
        self.produktgattungen = []
        self.schnelleVerbindungen = false
        self.sitzplatzOnly = false
        self.bikeCarriage = false
        self.reservierungsKontingenteVorhanden = false
        self.nurDeutschlandTicketVerbindungen = false
        self.deutschlandTicketVorhanden = false
        self.pagingReference = ""
        self.reisende = [Reisende.defaultValue]
        self.date = .now
    }
}

extension JourneyRequestIntBahnDe : JourneyRequest {
    init(
        settings : JourneySettings,
        dep : Stop,
        arr : Stop,
        time : Date,
        mode : LocationDirectionType,
        pagingReference: JourneyListViewModel.JourneyUpdateType?
    ) {
        self.init()
        self.addJourneyListTransfers(settings: settings)
        self.addJourneyOtherSettings(settings: settings)
        self.addJourneyListTransportModes(settings: settings)
        self.addJourneyListStops(dep: dep, arr: arr)
        self.addJourneyListTime(time: time, mode: mode)
        self.addPagingReference(ref: pagingReference)
    }
    
    init(
        request : Self,
        pagingReference: JourneyListViewModel.JourneyUpdateType?
    ) {
        self = request
        self.addPagingReference(ref: pagingReference)
    }
}
// MARK: - Ermaessigung (Discount) Model
struct Ermaessigung: ChewDTO {
    let art: String
    let klasse: String
}

extension Ermaessigung {
    static let defaultValue : Self = .init(
        art: "KEINE_ERMAESSIGUNG",
        klasse: "KLASSENLOS"
    )
}

extension JourneyRequestIntBahnDe {
    struct Reisende : ChewDTO {
        var typ : String
        var ermaessigungen : [Ermaessigung]
        var alter : [Int]
        var anzahl : Int
    }
    
}

extension JourneyRequestIntBahnDe.Reisende {
    static let defaultValue : Self = .init(typ: "ERWACHSENER",ermaessigungen: [.defaultValue],alter: [],anzahl: 1)
}

extension JourneyRequestIntBahnDe {
    mutating func addPagingReference(
        ref : JourneyListViewModel.JourneyUpdateType?
    ) {
        guard let ref = ref else {
            return
        }
        self.pagingReference = {
            switch ref {
                case .initial:
                    return ""
                case .earlierRef(let ref):
                    return ref ?? ""
                case .laterRef(let ref):
                    return ref ?? ""
            }
        }()
    }
    mutating func addJourneyListStops(
        dep: Stop,
        arr: Stop
    ) {
        self.abfahrtsHalt = dep.id
        self.ankunftsHalt = arr.id
    }
    
    mutating func addJourneyListTransfers(
        settings: JourneySettings
    ) {
        self.maxUmstiege = {
            switch settings.transferTime {
            case .direct:
                return 0
            case .time:
                switch settings.transferCount {
                case .unlimited:
                    return 11
                case .one:
                    return 1
                case .two:
                    return 2
                case .three:
                    return 3
                case .four:
                    return 4
                case .five:
                    return 5
                }
            }
        }()
    }
    
    mutating func addJourneyListTransportModes(
        settings: JourneySettings
    ) {
        self.produktgattungen = {
            switch settings.transportMode {
            case .all:
                return StopResponseIntlBahnDe.EndpointProducts.allCases.map{
                    $0.rawValue
                }
            case .regional:
                return [
                    StopResponseIntlBahnDe.EndpointProducts.regional.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.suburban.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.ferry.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.tram.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.taxi.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.subway.rawValue,
                    StopResponseIntlBahnDe.EndpointProducts.bus.rawValue
                ]
            case .custom:
                let products = settings.customTransferModes
                return products.compactMap {
                    $0.intbahndeEndpointProducts()?.rawValue
                }
            }
        }()
    }
    
    mutating func addJourneyListTime(
        time: Date,
        mode: LocationDirectionType
    ) {
        self.ankunftSuche = {
            switch mode {
            case .departure:
                return"ABFAHRT"
            case .arrival:
                return "ANKUNFT"
            }
        }()
        let formatter = DateFormatter()
        formatter.dateFormat = JourneyResponseIntBahnDe.formatDateAndTime
        
        let string = formatter.string(from: time)
        self.anfrageZeitpunkt = string
    }
    
    mutating func addJourneyOtherSettings(
        settings: JourneySettings
    ) {
        self.klasse = "KLASSE_2"
        self.bikeCarriage = settings.withBicycle
        self.sitzplatzOnly = false
        self.reservierungsKontingenteVorhanden = false
        self.deutschlandTicketVorhanden = false
        self.nurDeutschlandTicketVerbindungen = settings.transportMode == .regional
        self.schnelleVerbindungen = settings.fastestConnections
        
    }
}
//{
//    "abfahrtsHalt":"A=1@O=Neuss Hbf@X=6684523@Y=51204355@U=80@L=8000274@B=1@p=1738610742@i=U×008015149@",
//    "anfrageZeitpunkt":"2025-03-02T17:01:51",
//    "ankunftsHalt":"A=1@O=Düsseldorf Hbf@X=6794317@Y=51219960@U=80@L=8000085@B=1@p=1738610742@i=U×008008094@",
//    "ankunftSuche":"ABFAHRT",
//    "klasse":"KLASSE_2",
//    "produktgattungen":[
//        "ICE",
//        "EC_IC",
//        "IR",
//        "REGIONAL",
//        "SBAHN",
//        "BUS",
//        "SCHIFF",
//        "UBAHN",
//        "TRAM",
//        "ANRUFPFLICHTIG"
//    ],
//    "reisende":[
//        {
//            "typ":"ERWACHSENER",
//            "ermaessigungen":[
//                {
//                    "art":"KEINE_ERMAESSIGUNG",
//                    "klasse":"KLASSENLOS"
//                }
//            ],
//            [],
//            "anzahl":1
//        }
//    ],
//    "schnelleVerbindungen":false,
//    "sitzplatzOnly":false,
//    "bikeCarriage":false,
//    "reservierungsKontingenteVorhanden":false,
//    "nurDeutschlandTicketVerbindungen":false,
//    "deutschlandTicketVorhanden":false
//}
