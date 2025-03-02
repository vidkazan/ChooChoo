//
//  JourneyResponseI.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

// MARK: - Main Data Model
struct JourneyResponseIntBahnDe: JourneyResponse,ChewDTO {
    var id = UUID()
    let verbindungen: [Verbindung]
    let verbindungReference: VerbindungReference
}

// MARK: - Verbindung (Connection) Model
struct Verbindung: ChewDTO {
    let tripId: String
    let ctxRecon: String
    let verbindungsAbschnitte: [VerbindungsAbschnitt]
    let umstiegsAnzahl: Int
    let verbindungsDauerInSeconds: Int
    let ezVerbindungsDauerInSeconds: Int
    let isAlternativeVerbindung: Bool
    let auslastungsmeldungen: [Auslastungsmeldung]
    let auslastungstexte: [Auslastungstext]
    let himMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let risNotizen: [String] // Assuming this is an array of strings; adjust if necessary
    let priorisierteMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let reservierungsMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let isAngebotseinholungNachgelagert: Bool
    let isAlterseingabeErforderlich: Bool
    let hasTeilpreis: Bool
    let reiseAngebote: [String] // Assuming this is an array of strings; adjust if necessary
    let verbundCode: String
    let hinRueckPauschalpreis: Bool
    let isReservierungAusserhalbVorverkaufszeitraum: Bool
    let gesamtAngebotsbeziehungList: [String] // Assuming this is an array of strings; adjust if necessary
}

// MARK: - VerbindungsAbschnitt (Connection Section) Model
struct VerbindungsAbschnitt: ChewDTO {
    let risNotizen: [String] // Assuming this is an array of strings; adjust if necessary
    let himMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let priorisierteMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let externeBahnhofsinfoIdOrigin: String
    let externeBahnhofsinfoIdDestination: String
    let abfahrtsZeitpunkt: String
    let abfahrtsOrt: String
    let abfahrtsOrtExtId: String
    let abschnittsDauer: Int
    let abschnittsAnteil: Int
    let ankunftsZeitpunkt: String
    let ankunftsOrt: String
    let ankunftsOrtExtId: String
    let auslastungsmeldungen: [Auslastungsmeldung]
    let ezAbfahrtsZeitpunkt: String
    let ezAbschnittsDauerInSeconds: Int
    let ezAnkunftsZeitpunkt: String
    let halte: [Halt]
    let idx: Int
    let journeyId: String
    let verkehrsmittel: Verkehrsmittel
}

// MARK: - Halt (Stop) Model
struct Halt: ChewDTO {
    let id: String
    let abfahrtsZeitpunkt: String?
    let ankunftsZeitpunkt: String?
    let auslastungsmeldungen: [Auslastungsmeldung]
    let ezAbfahrtsZeitpunkt: String?
    let ezAnkunftsZeitpunkt: String?
    let gleis: String
    let platformType: PlatformType
    let haltTyp: String
    let name: String
    let risNotizen: [String] // Assuming this is an array of strings; adjust if necessary
    let bahnhofsInfoId: String
    let extId: String
    let himMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
    let routeIdx: Int
    let priorisierteMeldungen: [String] // Assuming this is an array of strings; adjust if necessary
}

// MARK: - PlatformType Model
struct PlatformType: ChewDTO {
    let code: String
    let shortDescription: String
    let longDescription: String
    let translations: [String: Translation]
}

// MARK: - Translation Model
struct Translation: ChewDTO {
    let shortDescription: String?
    let longDescription: String?
}

// MARK: - Verkehrsmittel (Transport) Model
struct Verkehrsmittel: ChewDTO {
    let produktGattung: String
    let kategorie: String
    let linienNummer: String
    let name: String
    let nummer: String
    let richtung: String
    let typ: String
    let zugattribute: [Zugattribute]
    let kurzText: String
    let mittelText: String
    let langText: String
}

// MARK: - Zugattribute (Train Attribute) Model
struct Zugattribute: ChewDTO {
    let kategorie: String
    let key: String
    let value: String
    let teilstreckenHinweis: String?
}

// MARK: - Auslastungsmeldung (Occupancy Report) Model
struct Auslastungsmeldung: ChewDTO {
    let klasse: String
    let stufe: Int
}

// MARK: - Auslastungstext (Occupancy Text) Model
struct Auslastungstext: ChewDTO {
    let klasse: String
    let stufe: Int
    let kurzText: String
    let anzeigeText: String?
    let langText: String?
}

// MARK: - VerbindungReference (Connection Reference) Model
struct VerbindungReference: ChewDTO {
    let earlier: String
    let later: String
}
