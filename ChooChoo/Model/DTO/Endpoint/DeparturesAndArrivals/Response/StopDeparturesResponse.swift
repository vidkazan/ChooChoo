//
//  StopDeparturesResponse.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 06.03.25.
//

import Foundation

struct StopDeparturesResponse: ChewDTO {
    let departure: [Departure]
    
    private enum CodingKeys : String, CodingKey {
        case departure = "entries"
    }
}

extension StopDeparturesResponse {
    struct Departure: ChewDTO {
        let bahnhofsId: String?
        let zeit: String?
        let ezZeit: String?
        let gleis: String?
        let ezGleis: String?
        let ueber: [String]?
        let journeyId: String?
        let meldungen: [Meldung]?
        let verkehrmittel: Verkehrsmittel?
        let terminus: String?
    }
}
//
//{
//    "entries": [
//        {
//            "bahnhofsId": "8000152",
//            "zeit": "2025-03-06T10:45:00",
//            "ezZeit": "2025-03-06T11:16:00",
//            "gleis": "11",
//            "ezGleis": "11",
//            "ueber": [
//                "Hannover Hbf",
//                "Nienburg(Weser)",
//                "Verden(Aller)",
//                "Bremen Hbf",
//                "Delmenhorst",
//                "Hude",
//                "Oldenburg(Oldb)Hbf",
//                "Norddeich Mole"
//            ],
//            "journeyId": "2|#VN#1#ST#1741032079#PI#0#ZI#277173#TA#0#DA#60325#1S#8010073#1T#601#LS#8007768#LT#1420#PU#80#RT#1#CA#ICd#ZE#2432#ZB#IC  2432#PC#1#FR#8010073#FT#601#TO#8007768#TT#1420#",
//            "meldungen": [],
//            "verkehrmittel": {
//                "name": "IC 2432",
//                "kurzText": "IC",
//                "mittelText": "IC 2432",
//                "langText": "IC 2432",
//                "produktGattung": "EC_IC"
//            },
//            "terminus": "Norddeich Mole"
//        },
//        {
//            "bahnhofsId": "8000152",
//            "zeit": "2025-03-06T10:55:00",
//            "ezZeit": "2025-03-06T10:55:00",
//            "gleis": "1",
//            "ezGleis": "1",
//            "ueber": [
//                "Hannover Hbf",
//                "Hannover Bismarckstr.",
//                "Hannover-Linden/Fischerhof",
//                "Weetzen",
//                "Holtensen/Linderte",
//                "Bennigsen",
//                "Völksen/Eldagsen",
//                "Paderborn Hbf"
//            ],
//            "journeyId": "2|#VN#1#ST#1741032079#PI#0#ZI#1122788#TA#2#DA#60325#1S#8002589#1T#1036#LS#8000297#LT#1246#PU#80#RT#1#CA#DPS#ZE#5#ZB#S      5#PC#4#FR#8002589#FT#1036#TO#8000297#TT#1246#",
//            "meldungen": [],
//            "verkehrmittel": {
//                "name": "S 5",
//                "linienNummer": "5",
//                "kurzText": "S",
//                "mittelText": "S 5",
//                "langText": "S 5",
//                "produktGattung": "SBAHN"
//            },
//            "terminus": "Paderborn Hbf"
//        }
//    ]
//}
