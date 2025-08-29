//
//  SelectionResponse.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

struct SelectionDTO: Decodable {
    let id: Int
    let fullName: String
    let genderCode: Int
    let orientationCode: Int
    let	age: Int
    let	aboutMe: String?
    let	searchStatusCode: Int
    let	voiceMessage: String
    let	photos: [String]
    let	video: String?
    let	distance: Int
    let page: Int
}

struct SelectionResponse: Decodable {
	let users: [SelectionDTO]
}

extension SelectionResponse {
	static let EMPTY = Self(
		users: [
			SelectionDTO(
				id: 0,
				fullName: "",
				genderCode: 0,
				orientationCode: 0,
				age: 0,
				aboutMe: "",
				searchStatusCode: 0,
				voiceMessage: "",
				photos: [],
				video: "",
				distance: 0,
                page: 1
			)
		]
	)
}
